// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libs/Global.sol";
import "../governance/PanaCoin.sol";
import "../PanaFactory.sol";
import "../api-governance/APIToken.sol";
import "hardhat/console.sol";

contract InvestmentPools is Ownable  {

    address public _fundingManager;
    PanaCoin public panaCoin;
    uint256 public amountForWhitelisting = 100e10;

    PanaFactory panaFactory;

    uint256 public poolCounter;

    // key: API Token address, value: PoolInfo
    mapping(address => Global.PoolInfo) public apiInvestmentPool;
    
    // key: User wallet address, value: Array of APIToken address for which PoolInfo was created
    // Mapping is used to store information about list of pools user has created
    mapping(address => address[]) public userInvestmentPools;
    // key: API Token address, value: PoolInvestmentDetails
    mapping(address => Global.PoolInvestmentDetails) public poolInvestmentDetails;

    // Key: API Token, Value: mapping Key: investor address Value: InvestoryDetails
    mapping(address => mapping (address => Global.InvestorDetails)) apiInvestors;

    // Key: User wallet address, Value: API Token list
    // It is related to apiInvestor property
    mapping(address => address[]) userInvestedAPITokenList;

    /*
    // Key: API Token, Value: Fund Available for Pool
    mapping(address => uint256) fundsAvailableForPools;
    // Key: API Token, Value: Number of API Tokens in contorl of investment pool
    mapping(address => uint256) numberOfAPITokensAvailable;
    */

    // Key: API Token, Value: investor address list 
    mapping(address => mapping(address=>bool)) whitelisters;
    
    // List of All Pools
    Global.PoolInfo[] public poolList;

    // Key: API Token Address, Value: Mapping= Key: User Address, value: true/false
    mapping(address => mapping(address => bool)) allowedList;

    uint256 public totalFundsApproved;
    uint256 public totalFundsAvailable;

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

    function initialize(address _panacoin, address _panaFactory) public onlyOwner {
        panaCoin = PanaCoin(_panacoin);
        panaFactory = PanaFactory(_panaFactory);
    }

    function fundingManager() public view returns (address) {
        return _fundingManager;
    }

    function setFundingManager(address fundingManagerAddress) public onlyOwner {
        _fundingManager = fundingManagerAddress;
    }

    function createInvestmentPool(address apiDev, address apiToken, uint256 startDate, 
                                uint256 endDate, uint256 tokenPrice, uint256 tokensToBeIssued, 
                                uint256 minimumInvestmentRequired, uint256 tokenPerInvestor,
                                uint256 whitelistingStartDate, uint256 whitelistingEndDate) 
                                public  {
        require(apiToken != address(0), "NULL API Token Address Provided");
        Global.PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
        _poolInfo.poolIndex = poolCounter;
        _poolInfo.apiToken = apiToken;
        _poolInfo.apiDev = apiDev;
        _poolInfo.startDate = startDate;
        _poolInfo.endDate = endDate;
        _poolInfo.tokenPrice = tokenPrice;
        _poolInfo.tokensToBeIssued = tokensToBeIssued;
        _poolInfo.minimumInvestmentRequired = minimumInvestmentRequired;
        _poolInfo.tokenPerInvestor = tokenPerInvestor;

        _poolInfo.poolFundingStatus = 1;
        _poolInfo.poolActive = true;

        userInvestmentPools[apiDev].push(apiToken);
        
        poolInvestmentDetails[apiToken] = Global.PoolInvestmentDetails(poolCounter,apiToken,whitelistingStartDate,whitelistingEndDate, 0, 0, 0, 0);
        
        poolList.push(_poolInfo);

        panaFactory.mintAPITokens(apiToken, address(this), tokensToBeIssued);
        //numberOfAPITokensAvailable[apiToken] = tokensToBeIssued;

        emit InvestmentPoolCreated(apiDev, apiToken, poolCounter);
        poolCounter++;
    }

    function createPaymentMilestoneClaim(address apiToken, uint256 amountToBeReleased) public onlyOwnerOrManager {
        require(apiInvestmentPool[apiToken].poolFundingStatus == 2, "Pool Should be successful");
        require((poolInvestmentDetails[apiToken].fundsAvailable > 0) && (poolInvestmentDetails[apiToken].fundsAvailable >= amountToBeReleased), "Funds not available");
        Global.PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
        if(_poolInfo.milestoneClaims.length > 0) {
            require(_poolInfo.milestoneClaims[_poolInfo.milestoneClaims.length-1].claimedTimestamp > 0, "Previous milestone amount not claimed");
        }
        require((amountToBeReleased + _poolInfo.totalFundApproved) <= poolInvestmentDetails[apiToken].fundCollected, "Not enough funds for Claim");

        _poolInfo.milestoneClaims.push(Global.MilestoneClaim(amountToBeReleased,block.timestamp, 0));
        _poolInfo.totalFundApproved += amountToBeReleased;
    }

    function claimMilestonePayment(address apiToken) public {
        require(apiInvestmentPool[apiToken].poolFundingStatus == 2, "Pool Should be successful");
        require(msg.sender == apiInvestmentPool[apiToken].apiDev);

        Global.PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
        require(_poolInfo.milestoneClaims.length > 0, "No claims available");
        Global.MilestoneClaim storage _milestoneClaim = _poolInfo.milestoneClaims[_poolInfo.milestoneClaims.length-1];
        require(_milestoneClaim.claimedTimestamp == 0, "Already Claimed amount");
        require(poolInvestmentDetails[apiToken].fundsAvailable >= _milestoneClaim.claimedAmount, "Funds not available");

        _poolInfo.milestoneClaims[_poolInfo.milestoneClaims.length-1].claimedTimestamp = block.timestamp;
        panaCoin.transfer(msg.sender, _milestoneClaim.claimedAmount);
        _poolInfo.fundsClaimed +=_milestoneClaim.claimedAmount;
        poolInvestmentDetails[apiToken].fundsAvailable -= _milestoneClaim.claimedAmount;
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
        require(apiInvestmentPool[_apiToken].poolFundingStatus == 1, "Investment not active");
        uint256 allowance = panaCoin.allowance(msg.sender, address(this));
        require(allowance >= _investmentAmount,"Insufficient approval for funds");
        
        Global.PoolInfo storage _poolInfo = apiInvestmentPool[_apiToken];
        Global.PoolInvestmentDetails storage _poolInvestmentDetail = poolInvestmentDetails[_apiToken];

        require(allowance >= _poolInfo.minimumInvestmentRequired,"Insufficient Investment Sent");

        uint256 tokenQuantity = (allowance / _poolInfo.tokenPrice) * 1e18;
        require( (tokenQuantity + _poolInvestmentDetail.tokenIssued)  <= _poolInfo.tokensToBeIssued,"Will exceed the total tokens allowed");
        require( (tokenQuantity + apiInvestors[_apiToken][msg.sender].claimableToken)  <= _poolInfo.tokenPerInvestor,"Per Investor token limit will exceed");

        panaCoin.transferFrom(msg.sender, address(this), _investmentAmount);
        _poolInvestmentDetail.fundCollected += _investmentAmount;
        _poolInvestmentDetail.tokenIssued += tokenQuantity;
        _poolInvestmentDetail.fundsAvailable += _investmentAmount;
        _poolInvestmentDetail.apiTokenAvailable += tokenQuantity;

        Global.InvestorDetails storage _investorDetails = apiInvestors[_apiToken][msg.sender];
        console.log("InvestorDetails.investor = ",_investorDetails.investor);
        console.log("InvestorDetails.apiToken = ",_investorDetails.apiToken);
        console.log("InvestorDetails.investedAmount = ",_investorDetails.investedAmount);
        console.log("InvestorDetails.claimableToken = ",_investorDetails.claimableToken);
        if(_investorDetails.apiToken == _apiToken) {
            console.log("In if  _investorDetails.apiToken == _apiToken");
            _investorDetails.investedAmount += _investmentAmount;
            _investorDetails.claimableToken += tokenQuantity;
        }
        else {
            console.log("In else  _investorDetails.apiToken == _apiToken");
            apiInvestors[_apiToken][msg.sender] = Global.InvestorDetails(msg.sender,_apiToken,_investmentAmount,tokenQuantity,0,0,0);
            userInvestedAPITokenList[msg.sender].push(_apiToken);
        }
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

    function updatetPoolFundingStatus (address _apiToken, uint256 poolFundingStatus) public onlyOwnerOrManager {
        require(poolFundingStatus >=1 && poolFundingStatus <=3, "Incorrect Status provided");
        apiInvestmentPool[_apiToken].poolFundingStatus = poolFundingStatus;
    }

    function getPoolFundingStatus (address _apiToken) public view returns(uint256) {
        return apiInvestmentPool[_apiToken].poolFundingStatus;
    }

    function togglePoolActiveStatus (address _apiToken) public onlyOwnerOrManager {
        apiInvestmentPool[_apiToken].poolActive = !apiInvestmentPool[_apiToken].poolActive;
    }

    function getPoolActiveStatus (address _apiToken) public view returns(bool) {
        return apiInvestmentPool[_apiToken].poolActive;
    }

    function claimFunds(address _apiToken) public {
        require(apiInvestmentPool[_apiToken].poolFundingStatus == 3, "Pool status is not failed");
        uint256 claimableFunds = apiInvestors[_apiToken][msg.sender].investedAmount;
        uint256 claimableTokens = apiInvestors[_apiToken][msg.sender].claimableToken;
        require(claimableFunds > 0, "No Funds to claim");
        require(poolInvestmentDetails[_apiToken].fundsAvailable >= claimableFunds, "All funds already refunded");
        require(totalFundsAvailable >= claimableFunds, "Funds not available");
        panaCoin.transfer(msg.sender, claimableFunds);
        apiInvestors[_apiToken][msg.sender].investedAmount = 0;
        apiInvestors[_apiToken][msg.sender].claimableToken = 0;
        apiInvestors[_apiToken][msg.sender].amountClaimed = claimableFunds;
        apiInvestors[_apiToken][msg.sender].claimedBlockNumber = block.number;
        poolInvestmentDetails[_apiToken].fundsAvailable -= claimableFunds;
        poolInvestmentDetails[_apiToken].apiTokenAvailable -= claimableTokens;
        totalFundsAvailable-= claimableFunds;
    }

    function getInvestorDetailForAPIToken(address _apiToken, address investor) public view returns(Global.InvestorDetails memory){
        return apiInvestors[_apiToken][investor];
    }

    function getInvestorPoolList(address investor) public view returns(Global.PoolInfo[] memory){
        address[] memory apiTokenAddressList = userInvestedAPITokenList[investor];
        console.log("investor = ",investor);
        console.log("userInvestedAPITokenList[investor].length = ",userInvestedAPITokenList[investor].length);
        console.log("apiTokenAddressList.length = ",apiTokenAddressList.length);
        Global.PoolInfo[] memory _poolInfoList = new Global.PoolInfo[](apiTokenAddressList.length);
        for (uint256 index = 0; index < apiTokenAddressList.length; index++) {
            console.log("index = ",index);
            console.log("apiTokenAddressList[index] = ",apiTokenAddressList[index]);
            console.log("apiInvestmentPool[apiTokenAddressList[index]].apiToken = ",apiInvestmentPool[apiTokenAddressList[index]].apiToken);
            _poolInfoList[index] = apiInvestmentPool[apiTokenAddressList[index]];
            console.log("after pool info list data");
        }
        return _poolInfoList;
    }

    
    function claimYourAPIToken(address _apiToken) public {
        require(apiInvestmentPool[_apiToken].poolFundingStatus == 2, "Pool status not Successful");
        Global.InvestorDetails storage _investorDetails = apiInvestors[_apiToken][msg.sender];
        require(_investorDetails.apiToken != address(0), "No investment in this pool");
        require(_investorDetails.claimableToken > 0, "No Tokens to claim");
        require(poolInvestmentDetails[_apiToken].apiTokenAvailable >= _investorDetails.claimableToken, "Not enough tokens available");
        
        APIToken apiToken = APIToken(_apiToken);
        apiToken.transfer(msg.sender, _investorDetails.claimableToken);

        _investorDetails.tokensClaimed = _investorDetails.claimableToken;
        _investorDetails.claimedBlockNumber = block.number;
        poolInvestmentDetails[_apiToken].apiTokenAvailable -= _investorDetails.claimableToken;
        _investorDetails.claimableToken = 0;
        //_investorDetails.investedAmount = 0;

    }

    function withdraw() public onlyOwner {
        address ownerAddress = owner(); 
        require(ownerAddress != address(0),"NULL Address Provided");
        panaCoin.transfer(ownerAddress, panaCoin.balanceOf(address(this)));
    }

}