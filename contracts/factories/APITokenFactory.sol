// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../Apitoken.sol";

library APITokenFactory {
    
    function generateAPIToken(string[] memory daoAndTokenDetails,
        uint256 maxApiTokenSupply, uint256 initialApiTokenSupply, uint256 developerSharePercentage,
        uint256 apiInvestorSharePercentage,uint256 _thresholdForSubscriberMinting) public returns(address){

            ApiToken apiToken = new ApiToken(daoAndTokenDetails[1],daoAndTokenDetails[2],maxApiTokenSupply,
                            initialApiTokenSupply,developerSharePercentage,apiInvestorSharePercentage,
                            0,0,_thresholdForSubscriberMinting);
            return address(apiToken);
    }
}