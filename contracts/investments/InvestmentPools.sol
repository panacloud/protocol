// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

// Central Point for all the contract to initialize
contract InvestmentPools is Ownable  {

    address public _fundingManager;

    modifier onlyOwnerOrManager() {
        require((owner() == _msgSender() || _fundingManager == _msgSender()), "InvestmentPools: caller is not the Owner or Manager");
        _;
    }

    uint256 public poolCounter;

    struct MilestoneClaim {
        uint256 claimedAmount;
        uint256 approvedTimestamp;
        uint256 claimedTimestamp;
    }

    struct PoolInfo {
        uint256 poolIndex;
        
        uint256 startDate;
        uint256 duration;
        uint256 tokenPrice;
        uint256 tokensToBeIssued;
        uint256 minimumInvestmentRequired;
        uint256 tokenPerInvestor;
        
        address apiToken;
        address apiDev;
        bool poolFundingSuccessfull;
        bool poolActive;        

        uint256 totalFundApproved;
        uint256 fundsAvailableFromClaim;
        uint256 fundsClaimed;

        MilestoneClaim[] milestoneClaims;

    }

    // key: API Token address, value: PoolInfo
    mapping(address => PoolInfo) public apiInvestmentPool;
    // key: User wallet address, value: Array of PoolInfo
    mapping(address => PoolInfo[]) public userInvestmentPools;
    // List of All Pools
    PoolInfo[] public poolList;

    uint256 private totalFundsApproved;
    uint256 private totalFundsAvailable;

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
                                uint256 minimumInvestmentRequired, uint256 tokenPerInvestor) 
                                public onlyOwnerOrManager {
        require(apiToken != address(0), "NULL API Token Address Provided");
        PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
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

        poolList[poolCounter]= _poolInfo;
    }

    function createPaymentMilestoneClaim(address apiToken, uint256 amountToBeReleased) public onlyOwnerOrManager {
        PoolInfo storage _poolInfo = apiInvestmentPool[apiToken];
        _poolInfo.milestoneClaims.push(MilestoneClaim(amountToBeReleased,block.timestamp, 0));
    }

}