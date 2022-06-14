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
}