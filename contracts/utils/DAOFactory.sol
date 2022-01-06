// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../api-governance/APIGovernor.sol";
import "../libs/Global.sol";


contract DAOFactory {
    
    /*
    function generateAPIDao(string[] memory apiDetails, string[] memory daoAndTokenDetails,
        uint256 votingSupportPercentage, uint256 votingMinimumApprovalPercentage, 
        uint256 voteDuration, address apiTokenAddress) public returns(address){

            APIDao apiDao = new APIDao(apiDetails[0],apiDetails[1],apiDetails[2],apiDetails[3],
                            daoAndTokenDetails[0],votingSupportPercentage,votingMinimumApprovalPercentage,
                            voteDuration, apiTokenAddress);
            return address(apiDao);
    }
    */

    function createAPIDao(address apiTimelock, Global.APIDAOConfig memory apiDAOConfig, address apiTokenAddress) public returns(address){
            APIGovernor apiDao = new APIGovernor();
            apiDao.initialize(apiTimelock, apiTokenAddress, apiDAOConfig.votingPeriod, 1, apiDAOConfig.proposalThresholdPercent, apiDAOConfig.quorumVotesPercent, apiDAOConfig.apiProposalId, apiDAOConfig.apiId, apiDAOConfig.daoName);
            /*
            APIDao apiDao = new APIDao(apiDAOConfig.apiProposalId,apiDAOConfig.apiId, apiDAOConfig.daoName,
                            apiDAOConfig.votingSupportPercentage,apiDAOConfig.votingMinimumApprovalPercentage,
                            apiDAOConfig.voteDuration, apiTokenAddress);*/
            return address(apiDao);
    }
}