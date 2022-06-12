// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./InvestmentPools.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../governance/PanaCoin.sol";

// Central Point for all the contract to initialize
contract InvestmentPoolsManager is Ownable  {

    InvestmentPools public investmentPools;
    PanaCoin public panaCoin;
    uint256 public amountForWhitelisting;

    // Key: API Token, Value: investor address list 
    mapping(address => address[]) whitelisters;

    function initialize(address _investmentPools, address _panacoin) public onlyOwner {
        investmentPools = InvestmentPools(_investmentPools);
        panaCoin = PanaCoin(_panacoin);
    }


    function applyForInvestmentPool(address _apiToken) public {
        uint256 availableBalance = panaCoin.balanceOf(msg.sender);
        require(availableBalance >= amountForWhitelisting, "Required Balance not available");
        //investmentPools.apiInvestmentPool[_apiToken].apiToken ==_apiToken;
    }

    function setAmountForWhitelisting(uint256 _amountForWhitelisting) public onlyOwner {
        amountForWhitelisting = _amountForWhitelisting;
    }


}