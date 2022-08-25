// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libs/Global.sol";

// Central Point for all the contract to initialize
contract InvestmentPools is Ownable  {

    address public _fundingManager;

    modifier onlyOwnerOrManager() {
        require((owner() == _msgSender() || _fundingManager == _msgSender()), "InvestmentPools: caller is not the Owner or Manager");
        _;
    }

    uint256 public poolCounter;

    // key: API Token address, value: PoolInfo
    mapping(address => Global.PoolInfo) public apiInvestmentPool;
    // key: User wallet address, value: Array of PoolInfo
    mapping(address => Global.PoolInfo[]) public userInvestmentPools;
    // key: API Token address, value: WhitelistCriteria
    mapping(address => Global.WhitelistCriteria) public apiWhitelistCriteria;
    
    // List of All Pools
    Global.PoolInfo[] public poolList;

    // Key: API Token Address, Value: Mapping= Key: User Address, value: true/false
    mapping(address => mapping(address => bool)) allowedList;

    uint256 private totalFundsApproved;
    uint256 private totalFundsAvailable;

    event InvestmentPoolCreated(address apiDev, address apiToken, uint256 poolIndex);
    event PaymentMilestoneClaimCreated(address apiToken, uint256 amountToBeReleased);

    constructor() {
    }

    function fundingManager() public view returns (address) {
        return _fundingManager;
    }

    function setFundingManager(address fundingManagerAddress) public onlyOwner {
        _fundingManager = fundingManagerAddress;
    }

    function createInvestmentPool(address apiDev, address apiToken, uint256 startDate, 
                                uint256 duration, uint256 tokenPrice, uint256 tokensToBeIssued, 
                                uint256 minimumInvestmentRequired, uint256 tokenPerInvestor,
                                uint256 whitelistingStartDate, uint256 whitelistingEndDate) 
                                public  {
        require(apiToken != address(0), "NULL API Token Address Provided");
        Global.PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
        _poolInfo.poolIndex = poolCounter;
        _poolInfo.apiToken = apiToken;
        _poolInfo.apiDev = apiDev;
        _poolInfo.startDate = startDate;
        _poolInfo.duration = duration;
        _poolInfo.tokenPrice = tokenPrice;
        _poolInfo.tokensToBeIssued = tokensToBeIssued;
        _poolInfo.minimumInvestmentRequired = minimumInvestmentRequired;
        _poolInfo.tokenPerInvestor = tokenPerInvestor;

        _poolInfo.poolFundingSuccessfull = false;
        _poolInfo.poolActive = true;

        userInvestmentPools[apiDev].push(_poolInfo);

        apiWhitelistCriteria[apiToken] = Global.WhitelistCriteria(poolCounter,apiToken,whitelistingStartDate,whitelistingEndDate);

        poolList.push(_poolInfo);
        emit InvestmentPoolCreated(apiDev, apiToken, poolCounter);
        poolCounter++;
    }

    function createPaymentMilestoneClaim(address apiToken, uint256 amountToBeReleased) public onlyOwnerOrManager {
        Global.PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
        _poolInfo.milestoneClaims.push(Global.MilestoneClaim(amountToBeReleased,block.timestamp, 0));

    }

    function getInvestmentPool(address _apiToken) public view returns (Global.PoolInfo memory) {
        return apiInvestmentPool[_apiToken];
    }

    function getWhitelistCriteria(address _apiToken) public view returns (Global.WhitelistCriteria memory) {
        return apiWhitelistCriteria[_apiToken];
    }

    function getPoolInfoList() public view returns (Global.PoolInfo[] memory) {
        return poolList;
    }

}