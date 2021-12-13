// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../APIDao.sol";
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

    function createAPIDao(Global.APIDAOConfig memory apiDAOConfig, address apiTokenAddress) public returns(address){

            APIDao apiDao = new APIDao(apiDAOConfig.apiProposalId,apiDAOConfig.apiId, apiDAOConfig.daoName,
                            apiDAOConfig.votingSupportPercentage,apiDAOConfig.votingMinimumApprovalPercentage,
                            apiDAOConfig.voteDuration, apiTokenAddress);
            return address(apiDao);
    }
}