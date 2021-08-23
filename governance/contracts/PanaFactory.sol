// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APIIdeaNFT.sol";

// Need to decide if we really need a factory or not
// creating a smart contract for factory will cost us
contract PanaFactory is Ownable  {

    address private apiIdeaNFTAddress;
    address private panaCoinAddress;

    function initialize(address _panaCoin, address _apiIdeaNFT) public onlyOwner {
        panaCoinAddress = _panaCoin;
        apiIdeaNFTAddress = _apiIdeaNFT;
    }

    function generateAPIIdeaNFT(address ideaOwnerAddress) public onlyOwner returns(uint256) {
        APIIdeaNFT ideaNFT = APIIdeaNFT(apiIdeaNFTAddress);
        return ideaNFT.safeMint(ideaOwnerAddress);
    }

    function generateAPIDao() public onlyOwner {

    } 

}