// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../APIToken.sol";
import "../libs/Global.sol";

contract APITokenFactory {
    
    /*
    function generateAPIToken(string[] memory daoAndTokenDetails,
        uint256 maxApiTokenSupply, uint256 initialApiTokenSupply, uint256 developerSharePercentage,
        uint256 apiInvestorSharePercentage,uint256 _thresholdForSubscriberMinting,address _paymentSplitterAddress) public returns(address){

            APIToken apiToken = new APIToken(daoAndTokenDetails[1],daoAndTokenDetails[2],maxApiTokenSupply,
                            initialApiTokenSupply,developerSharePercentage,apiInvestorSharePercentage,
                            0,0,_thresholdForSubscriberMinting,_paymentSplitterAddress);
            return address(apiToken);
    }
    */
    function createAPIToken(Global.APITokenConfig memory apiTokenConfig, uint256 panacloudShareInAPI, 
                                uint256 apiIdeaProposerShare, address _paymentSplitterAddress) 
                                public returns(address){
            APIToken apiToken = new APIToken(apiTokenConfig.apiTokenName,apiTokenConfig.apiTokenSymbol, apiTokenConfig.maxApiTokenSupply,
                            apiTokenConfig.initialApiTokenSupply,apiTokenConfig.developerSharePercentage,apiTokenConfig.apiInvestorSharePercentage,
                            apiTokenConfig.thresholdForSubscriberMinting, panacloudShareInAPI, apiIdeaProposerShare, _paymentSplitterAddress);
            return address(apiToken);
    }
}