// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./InvestmentPools.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../governance/PanaCoin.sol";
import "../libs/Global.sol";

// Central Point for all the contract to initialize
contract InvestmentPoolsManager is Ownable  {

    InvestmentPools public investmentPools;
    PanaCoin public panaCoin;
    uint256 public amountForWhitelisting = 100e10;

    // Key: API Token, Value: investor address list 
    mapping(address => mapping(address=>bool)) whitelisters;
    //mapping(address => )

    function initialize(address _investmentPools, address _panacoin) public onlyOwner {
        investmentPools = InvestmentPools(_investmentPools);
        panaCoin = PanaCoin(_panacoin);
    }


    function applyForInvestmentPool(address _apiToken) public {
        uint256 availableBalance = panaCoin.balanceOf(msg.sender);
        require(availableBalance >= amountForWhitelisting, "Required Balance not available");
        Global.PoolInfo memory _poolInfo = investmentPools.getInvestmentPool(_apiToken);
        require(_poolInfo.apiToken == _apiToken, "Pool Not found");
        whitelisters[_apiToken][msg.sender] = true;
    }

    function setAmountForWhitelisting(uint256 _amountForWhitelisting) public onlyOwner {
        amountForWhitelisting = _amountForWhitelisting;
    }

    function investInPool(address _apiToken, uint256 _investmentAmount) public {
        require(whitelisters[_apiToken][msg.sender], "Not Whitelisted");
        uint256 allowance = panaCoin.allowance(msg.sender, address(this));
        //Global.PoolInfo memory _poolInfo = investmentPools.getInvestmentPool(_apiToken);
        //require(allowance >= (price * tokenQuantity),"Insufficient approval for funds");
        require(allowance >= _investmentAmount,"Insufficient approval for funds");
        panaCoin.transferFrom(msg.sender, address(this), _investmentAmount);
    }


}