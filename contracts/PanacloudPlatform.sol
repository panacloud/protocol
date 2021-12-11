// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract PanacloudPlatform is Ownable {

    uint256 public panacloudShareInAPI = 5;
    uint256 public apiIdeaProposerShare = 1;

    // Key DAO address value Developer address
    mapping(address => address) private apiDAOToUserMapping;

    // Mapping for developer to list of owned DAOs
    // key:develper address, value: Dao Address array
    mapping(address => address[]) private ownedDAOs;

    // Mapping for developer to list of owned Tokens
    // key:develper address, value: Dao Address array
    mapping(address => address[]) private ownedTokens;

    address public paymentSplitterAddress;

    constructor() {
        console.log("Platform Launched");
    }

    function initialize(address _paymentSplitterAddress) public onlyOwner {
        paymentSplitterAddress = _paymentSplitterAddress;
    }

    function setPanacloudAPIShare(uint256 newShare) public onlyOwner {
        require(newShare > 1, "Platform Share must be greater than 1");
        require(newShare <= 50, "Platform Share cannot be greater than 50");
        panacloudShareInAPI = newShare;
    }

    function setAPIIdeaProposerShare(uint256 newShare) public onlyOwner {
        require(newShare > 0, "Idea Proposer Share must be greater than 0");
        require(newShare <= 10, "Idea Proposer Share cannot be greater than 10");
        apiIdeaProposerShare = newShare;
    }

    function apiDAOCreated(address owner, address apiDao, address apiToken) public {
        apiDAOToUserMapping[apiDao] = owner;
        ownedDAOs[owner].push(apiDao);
        ownedTokens[owner].push(apiToken);
    }

}