// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APINFT.sol";
import "./PanacloudPlatform.sol";
import "./factories/DaoFactory.sol";
import "./factories/APITokenFactory.sol";

// Need to decide if we really need a factory or not
// creating a smart contract for factory will cost us
contract PanaFactory is Ownable  {

    address private apiNFTAddress;
    address private panaCoinAddress;
    address private panacloudPlatformAddress;

    function initialize(address _panaCoin, address _apiNFT, address _panacloudPlatform) public onlyOwner {
        panaCoinAddress = _panaCoin;
        apiNFTAddress = _apiNFT;
        panacloudPlatformAddress = _panacloudPlatform;
    }

    function generateAPIIdeaNFT(address ideaOwnerAddress) public returns(uint256) {
        APINFT ideaNFT = APINFT(apiNFTAddress);
        return ideaNFT.safeMint(ideaOwnerAddress);
    }

    // votingSupportPercentage - Support is the relative percentage of tokens that are required to 
    // vote “Yes” for a proposal to be approved. For example, if “Support” is set to 50%, then  
    // more than 50% of the tokens used to vote on a proposal must vote “Yes” for it to pass.

    // votingMinimumApprovalPercentage - Minimum Approval is the percentage of the total token supply 
    // that is required to vote “Yes” on a proposal before it can be approved. For example, if 
    // the “Minimum Approval” is set to 20%, then more than 20% of the outstanding token supply 
    // must vote “Yes” on a proposal for it to pass.
    
    /**
        apiDetails Array 
        Index 0 - API PorposalId
        Index 1 - API ID, this will be used in API URL
        Index 2 - API Title 
        Index 3 - API Type
        
        daoAndTokenDetails Array 
        Index 0 - API DAO Name
        Index 1 - API Token Name
        Index 2 - API Token Symbol
     */   
    function generateAPIDao(string[] memory apiDetails, string[] memory daoAndTokenDetails,
        uint256 maxApiTokenSupply, uint256 initialApiTokenSupply, uint256 developerSharePercentage,
        uint256 apiInvestorSharePercentage, uint256 votingSupportPercentage, 
        uint256 votingMinimumApprovalPercentage, uint256 voteDuration, uint256 _thresholdForSubscriberMinting,
        address _paymentSplitterAddress) public {
        
        address apiTokenAddress = APITokenFactory.generateAPIToken(daoAndTokenDetails, maxApiTokenSupply, initialApiTokenSupply, developerSharePercentage, apiInvestorSharePercentage, _thresholdForSubscriberMinting,_paymentSplitterAddress);
        address apiDaoAddress = DaoFactory.generateAPIDao(apiDetails, daoAndTokenDetails, votingSupportPercentage, votingMinimumApprovalPercentage, voteDuration, address(apiTokenAddress));
        
        PanacloudPlatform platfrom = PanacloudPlatform(panacloudPlatformAddress);
        
        platfrom.apiDAOCreated(msg.sender, address(apiDaoAddress), address(apiTokenAddress));
        
    }
    /*
    function generateAPIToken(string[] memory apiDetails, string[] memory daoAndTokenDetails,
        uint256 maxApiTokenSupply, uint256 initialApiTokenSupply, uint256 developerSharePercentage,
        uint256 apiInvestorSharePercentage, uint256 votingSupportPercentage, 
        uint256 votingMinimumApprovalPercentage, uint256 voteDuration, uint256 _thresholdForSubscriberMinting) public {
        
        
        PanacloudPlatform platfrom = PanacloudPlatform(panacloudPlatformAddress);
        
        ApiToken apiToken = new ApiToken(daoAndTokenDetails[1],daoAndTokenDetails[2],maxApiTokenSupply,
                            initialApiTokenSupply,developerSharePercentage,apiInvestorSharePercentage,
                            platfrom.panacloudAPIShare(),platfrom.apiIdeaProposerShare(),_thresholdForSubscriberMinting);
        
        
        APIDao apiDao = new APIDao(apiDetails[0],apiDetails[1],apiDetails[2],apiDetails[3],
                            daoAndTokenDetails[0],votingSupportPercentage,votingMinimumApprovalPercentage,
                            voteDuration, address(0));
        
        platfrom.apiDAOCreated(msg.sender, address(apiDao), address(0));
        
    }
    */
    /*
    function generateAPIDao(string memory apiProposalId, string memory apiID, 
            string memory apiTitle, string memory apiType, string memory apiDaoName,
            string memory apiTokenName, string memory apiTokenSymbol, int256 maxApiTokenSupply, 
            int256 initialApiTokenSupply,int8 developerSharePercentage, int8 apiProposerSharePercentage,
            uint8 apiInvestorySharePercentage, uint8 platformSharePercentage,
            uint8 votingSupportPercentage, uint8 votingMinimumApprovalPercentage, 
            uint256 voteDuration) public {

    } */

}