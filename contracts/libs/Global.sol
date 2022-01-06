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
}