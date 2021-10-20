// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract PanacloudPlatform is Ownable {

    uint256 public panacloudAPIShare = 5;
    uint256 public apiIdeaProposerShare = 1;

    constructor() {
        console.log("Platform Launched");
    }

    function setPanacloudAPIShare(uint256 newShare) public onlyOwner {
        require(newShare > 1, "Platform Share must be greater than 1");
        require(newShare <= 50, "Platform Share cannot be greater than 50");
        panacloudAPIShare = newShare;
    }

    function setAPIIdeaProposerShare(uint256 newShare) public onlyOwner {
        require(newShare > 0, "Idea Proposer Share must be greater than 0");
        require(newShare <= 10, "Idea Proposer Share cannot be greater than 10");
        apiIdeaProposerShare = newShare;
    }

}