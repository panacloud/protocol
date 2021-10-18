// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APINFT.sol";

// Need to decide if we really need a factory or not
// creating a smart contract for factory will cost us
contract PanaFactory is Ownable  {

    address private apiNFTAddress;
    address private panaCoinAddress;

    function initialize(address _panaCoin, address _apiNFT) public onlyOwner {
        panaCoinAddress = _panaCoin;
        apiNFTAddress = _apiNFT;
    }

    function generateAPIIdeaNFT(address ideaOwnerAddress) public onlyOwner returns(uint256) {
        APINFT ideaNFT = APINFT(apiNFTAddress);
        return ideaNFT.safeMint(ideaOwnerAddress);
    }

    function generateAPIDao() public onlyOwner {

    } 

}