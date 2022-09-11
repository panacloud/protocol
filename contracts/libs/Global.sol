// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library Global {

    struct APIDAOConfig {
        string apiProposalId;
        string apiId;
        //string apiTitle;
        //string apiType;
        string daoName;
        uint256 proposalThresholdPercent; //votingMinimumApprovalPercentage;
        uint256 quorumVotesPercent; //votingSupportPercentage;
        uint256 votingPeriod; //voteDuration;
    }

    struct APITokenConfig {
        string apiTokenName;
        string apiTokenSymbol;
        uint256 maxApiTokenSupply;
        uint256 initialApiTokenSupply;
        uint256 developerSharePercentage;
        uint256 apiInvestorSharePercentage;
        uint256 thresholdForSubscriberMinting; // Still needs to see what it will do
    }

    // For Investment Pools
    struct MilestoneClaim {
        uint256 claimedAmount;
        uint256 approvedTimestamp;
        uint256 claimedTimestamp;
    }

    // For Investment Pools
    // This struct will be used together PoolInvestmentDetails
    struct PoolInfo {
        uint256 poolIndex;
        
        uint256 startDate;
        uint256 endDate;
        uint256 tokenPrice;
        uint256 tokensToBeIssued;
        uint256 minimumInvestmentRequired;
        uint256 tokenPerInvestor;

        address apiToken;
        address apiDev;
        uint256 poolFundingStatus; //1=In Progress, 2=Successfull, 3=Failed 
        bool poolActive;      

        uint256 totalFundApproved;
        uint256 fundsAvailableFromClaim; // Not used for now
        uint256 fundsClaimed;

        MilestoneClaim[] milestoneClaims;

    }

    // This struct will be used together PoolInfo
    struct PoolInvestmentDetails {
        uint256 poolIndex;
        address apiToken;

        uint256 whitelistingStartDate;
        uint256 whitelistingEndDate;
        
        uint256 fundCollected;
        uint256 tokenIssued;

        // 1) Running balance of funds used, in case of pool failure as user claim funds this property 
        // will track recent available funds and deduction will be done in it
        // The property is related to 'fundCollected'
        // 2) In case of success fundsAvailable will used as reference for api developer to withdraw funds
        uint256 fundsAvailable; 

        // Running balance of api tokens, in case of pool success as user claim api tokens this 
        // property will track recent available tokens and deduction will be done in it
        // The property is related to 'tokenIssued'
        uint256 apiTokenAvailable; 

    }

    struct InvestorDetails {
        address investor;
        address apiToken;
        uint256 investedAmount;
        uint256 claimableToken;

        uint256 claimedBlockNumber; // This will works in case of both failure and success
        //In case of failure
        uint256 amountClaimed;

        //In case of success
        uint256 tokensClaimed;
    }

    struct AllowedUser {
        address investor;
        uint256 investedTokenAmount;
        uint256 claimableTokenAmount;
        uint256 status; //1=Applied, 2=Pre-Selected, 3=KYC Open, 4=Allowlisted, 5=Unlucky, 6=Cooldown Period
        
    }
}