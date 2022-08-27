// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libs/Global.sol";
import "../governance/PanaCoin.sol";
import "hardhat/console.sol";

contract InvestmentPools is Ownable  {

    address public _fundingManager;
    PanaCoin public panaCoin;
    uint256 public amountForWhitelisting = 100e10;

    uint256 public poolCounter;

    // key: API Token address, value: PoolInfo
    mapping(address => Global.PoolInfo) public apiInvestmentPool;
    
    // key: User wallet address, value: Array of APIToken address for which PoolInfo was created
    // Mapping is used to store information about list of pools user has created
    mapping(address => address[]) public userInvestmentPools;
    // key: API Token address, value: PoolInvestmentDetails
    mapping(address => Global.PoolInvestmentDetails) public poolInvestmentDetails;

    // Key: API Token, Value: investor address and investment amount mapping
    mapping(address => mapping (address => uint256)) apiInvestorAmount;

    // Key: API Token, Value: Fund collected -- need to see if its needed 
    mapping(address => uint256) fundsCollectedForPools;

    // Key: API Token, Value: investor address list 
    mapping(address => mapping(address=>bool)) whitelisters;
    
    // List of All Pools
    Global.PoolInfo[] public poolList;

    // Key: API Token Address, Value: Mapping= Key: User Address, value: true/false
    mapping(address => mapping(address => bool)) allowedList;

    uint256 private totalFundsApproved;
    uint256 private totalFundsAvailable;

    event InvestmentPoolCreated(address apiDev, address apiToken, uint256 poolIndex);
    event PaymentMilestoneClaimCreated(address apiToken, uint256 amountToBeReleased);
    
    event AppliedForInvestmentPool(address apiToken, address userAddress);
    event InvestedInPool(address apiToken, uint256 investmentAmount, address userAddress);



    modifier onlyOwnerOrManager() {
        require((owner() == _msgSender() || _fundingManager == _msgSender()), "InvestmentPools: caller is not the Owner or Manager");
        _;
    }

    constructor() {
    }

    function initialize(address _panacoin) public onlyOwner {
        panaCoin = PanaCoin(_panacoin);
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

        _poolInfo.poolFundingStatus = 1;
        _poolInfo.poolActive = true;

        userInvestmentPools[apiDev].push(apiToken);
        
        poolInvestmentDetails[apiToken] = Global.PoolInvestmentDetails(poolCounter,apiToken,whitelistingStartDate,whitelistingEndDate, 0, 0, false);
        
        poolList.push(_poolInfo);
        emit InvestmentPoolCreated(apiDev, apiToken, poolCounter);
        poolCounter++;
    }

    function createPaymentMilestoneClaim(address apiToken, uint256 amountToBeReleased) public onlyOwnerOrManager {
        Global.PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
        _poolInfo.milestoneClaims.push(Global.MilestoneClaim(amountToBeReleased,block.timestamp, 0));
    }

    function applyForInvestmentPool(address _apiToken) public {
        console.log("Inside applyForInvestmentPool api token = ",_apiToken);
        uint256 availableBalance = panaCoin.balanceOf(msg.sender);
        console.log("after availableBalance = ",availableBalance);
        require(availableBalance >= amountForWhitelisting, "Required Balance not available");
        //Global.PoolInfo memory _poolInfo = investmentPools.getInvestmentPool(_apiToken);
        //Global.PoolInvestmentDetails memory _poolInvestmentDetail = investmentPools.getPoolInvestmentDetails(_apiToken);
        Global.PoolInfo memory _poolInfo = apiInvestmentPool[_apiToken];
        Global.PoolInvestmentDetails memory _poolInvestmentDetail = poolInvestmentDetails[_apiToken];
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
        
        Global.PoolInfo memory _poolInfo = apiInvestmentPool[_apiToken];
        Global.PoolInvestmentDetails memory _poolInvestmentDetail = poolInvestmentDetails[_apiToken];

        require(allowance >= _poolInfo.minimumInvestmentRequired,"Insufficient Investment Sent");

        uint256 tokenQuantity = allowance / _poolInfo.tokenPrice;
        require( (tokenQuantity + _poolInvestmentDetail.tokenIssued)  <= _poolInfo.tokensToBeIssued,"Will exceed the total tokens allowed");
        require( (tokenQuantity + apiInvestorAmount[_apiToken][msg.sender])  <= _poolInfo.tokenPerInvestor,"Per Investor token limit will exceed");

        panaCoin.transferFrom(msg.sender, address(this), _investmentAmount);
        _poolInvestmentDetail.fundCollected += _investmentAmount;
        _poolInvestmentDetail.tokenIssued += tokenQuantity;
        apiInvestorAmount[_apiToken][msg.sender]+=tokenQuantity;
        totalFundsAvailable += _investmentAmount;
        if(_poolInfo.tokensToBeIssued == _poolInvestmentDetail.tokenIssued) {
            _poolInfo.poolFundingStatus = 2;
        }

        emit InvestedInPool(_apiToken, _investmentAmount, msg.sender);
    }

    function getInvestmentPool(address _apiToken) public view returns (Global.PoolInfo memory) {
        return apiInvestmentPool[_apiToken];
    }

    function getPoolInvestmentDetails(address _apiToken) public view returns (Global.PoolInvestmentDetails memory) {
        return poolInvestmentDetails[_apiToken];
    }

    function getPoolInfoList() public view returns (Global.PoolInfo[] memory) {
        return poolList;
    }

    function updatetPoolFundingStatus (address _apiToken, uint256 poolFundingStatus) public onlyOwner {
        require(poolFundingStatus >=1 && poolFundingStatus <=3, "Incorrect Status provided");
        apiInvestmentPool[_apiToken].poolFundingStatus = poolFundingStatus;
    }

    function togglePoolActiveStatus (address _apiToken) public onlyOwner {
        apiInvestmentPool[_apiToken].poolActive = !apiInvestmentPool[_apiToken].poolActive;
    }

    function claimFunds(address _apiToken) public {
        require(apiInvestmentPool[_apiToken].poolFundingStatus == 3, "Pool status is not failed");
        uint256 claimableFunds = apiInvestorAmount[_apiToken][msg.sender];
        require(claimableFunds > 0, "No Funds to claim");
        panaCoin.transfer(msg.sender, claimableFunds);
    }

    function withdraw() public onlyOwner {
        address ownerAddress = owner(); 
        require(ownerAddress != address(0),"NULL Address Provided");
        panaCoin.transfer(ownerAddress, panaCoin.balanceOf(address(this)));
    }

}