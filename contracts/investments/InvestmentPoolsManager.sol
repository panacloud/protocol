// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./InvestmentPools.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../governance/PanaCoin.sol";
import "../libs/Global.sol";
import "hardhat/console.sol";

//TODO: This contract will be removed
contract InvestmentPoolsManager is Ownable  {

    InvestmentPools public investmentPools;
    PanaCoin public panaCoin;
    uint256 public amountForWhitelisting = 100e10;

    // Key: API Token, Value: investor address list 
    mapping(address => mapping(address=>bool)) whitelisters;
    //mapping(address => )

    // Key: API Token, Value: Fund collected 
    mapping(address => uint256) fundsCollectedForPools;

    event AppliedForInvestmentPool(address apiToken, address userAddress);
    event InvestedInPool(address apiToken, uint256 investmentAmount, address userAddress);

    function initialize(address _investmentPools, address _panacoin) public onlyOwner {
        investmentPools = InvestmentPools(_investmentPools);
        panaCoin = PanaCoin(_panacoin);
    }

    function applyForInvestmentPool(address _apiToken) public {
        console.log("Inside applyForInvestmentPool api token = ",_apiToken);
        uint256 availableBalance = panaCoin.balanceOf(msg.sender);
        console.log("after availableBalance = ",availableBalance);
        require(availableBalance >= amountForWhitelisting, "Required Balance not available");
        Global.PoolInfo memory _poolInfo = investmentPools.getInvestmentPool(_apiToken);
        Global.PoolInvestmentDetails memory _poolInvestmentDetail = investmentPools.getPoolInvestmentDetails(_apiToken);
        console.log("Global.PoolInfo.apiToken = ",_poolInfo.apiToken);
        console.log("Global.PoolInfo.apiDev = ",_poolInfo.apiDev);
        console.log("Global.PoolInfo.startDate = ",_poolInfo.startDate);
        console.log("Global.PoolInfo.tokensToBeIssued = ",_poolInfo.tokensToBeIssued);
        
        console.log("Global.WhitelistCriteria.whitelistingStartDate = ",_poolInvestmentDetail.whitelistingStartDate);
        console.log("Global.WhitelistCriteria.whitelistingEndDate = ",_poolInvestmentDetail.whitelistingEndDate);
        console.log("block.timestamp = ",block.timestamp);

        require(block.timestamp >= _poolInvestmentDetail.whitelistingStartDate && block.timestamp<= _poolInvestmentDetail.whitelistingEndDate, "Whitelisting start and end time not match");
        require(_poolInfo.apiToken == _apiToken, "Pool Not found");
        whitelisters[_apiToken][msg.sender] = true;
        emit AppliedForInvestmentPool(_apiToken, msg.sender);
    }

    function setAmountForWhitelisting(uint256 _amountForWhitelisting) public onlyOwner {
        amountForWhitelisting = _amountForWhitelisting;
    }

    function investInPool(address _apiToken, uint256 _investmentAmount) public {
        require(whitelisters[_apiToken][msg.sender], "Not Whitelisted");
        uint256 allowance = panaCoin.allowance(msg.sender, address(this));
        require(allowance >= _investmentAmount,"Insufficient approval for funds");
        
        Global.PoolInfo memory _poolInfo = investmentPools.getInvestmentPool(_apiToken);
        Global.PoolInvestmentDetails memory _poolInvestmentDetail = investmentPools.getPoolInvestmentDetails(_apiToken);

        require(allowance >= _poolInfo.minimumInvestmentRequired,"Insufficient Investment Sent");

        uint256 tokenQuantity = allowance / _poolInfo.tokenPrice;
        require( (tokenQuantity + _poolInvestmentDetail.tokenIssued)  <= _poolInfo.tokensToBeIssued,"Insufficient Investment Sent");
        //require(allowance >= (price * tokenQuantity),"Insufficient approval for funds");

        panaCoin.transferFrom(msg.sender, address(this), _investmentAmount);
        emit InvestedInPool(_apiToken, _investmentAmount, msg.sender);
    }


}