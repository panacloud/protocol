// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APINFT.sol";
import "./PanacloudPlatform.sol";
import "./utils/DAOFactory.sol";
import "./utils/APITokenFactory.sol";
import "./libs/Global.sol";

// Need to decide if we really need a factory or not
// creating a smart contract for factory will cost us
contract PanaFactory is Ownable  {

    address private apiNFTAddress;
    address private panaCoinAddress;
    address private panacloudPlatformAddress;
    address private apiTokenFactoryAddress;
    address private daoFactoryAddress;
    DAOFactory private daoFactory;
    APITokenFactory private apiTokenFactory;

    function initialize(address _panaCoin, address _apiNFT, address _panacloudPlatform, 
                        address _apiTokenFactoryAddress, address _daoFactoryAddress) public onlyOwner {
        panaCoinAddress = _panaCoin;
        apiNFTAddress = _apiNFT;
        panacloudPlatformAddress = _panacloudPlatform;
        apiTokenFactoryAddress = _apiTokenFactoryAddress;
        daoFactoryAddress = _daoFactoryAddress;
        daoFactory = DAOFactory(_daoFactoryAddress);
        apiTokenFactory = APITokenFactory(_apiTokenFactoryAddress);

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
    function createAPIDao(Global.APITokenConfig memory apiTokenConfig, 
                            Global.APIDAOConfig memory apiDAOConfig) public {
        
        
        PanacloudPlatform platfrom = PanacloudPlatform(panacloudPlatformAddress);

        // Need to fix msg.sender -- as API's owner will be API token factory, which is incorrect
        address apiTokenAddress = apiTokenFactory.createAPIToken(apiTokenConfig, 
                                                            platfrom.panacloudShareInAPI(),
                                                            platfrom.apiIdeaProposerShare(),
                                                            platfrom.paymentSplitterAddress());
        
        // Need to fix msg.sender -- as DAO's owner will be DAO factory, which is incorrect
        address apiDaoAddress = daoFactory.createAPIDao(apiDAOConfig, apiTokenAddress);
        
        platfrom.apiDAOCreated(msg.sender, apiDAOConfig.apiId, address(apiTokenAddress), address(apiDaoAddress));
        
    }

    /*
    function generateAPIDao(string[] memory apiDetails, string[] memory daoAndTokenDetails,
        uint256 maxApiTokenSupply, uint256 initialApiTokenSupply, uint256 developerSharePercentage,
        uint256 apiInvestorSharePercentage, uint256 votingSupportPercentage, 
        uint256 votingMinimumApprovalPercentage, uint256 voteDuration, uint256 _thresholdForSubscriberMinting) public pure{

        PanacloudPlatform platfrom = PanacloudPlatform(panacloudPlatformAddress);

        address apiTokenAddress = apiTokenFactory.generateAPIToken(daoAndTokenDetails, maxApiTokenSupply,
                                        initialApiTokenSupply, developerSharePercentage, 
                                        apiInvestorSharePercentage, _thresholdForSubscriberMinting, 
                                        platfrom.paymentSplitterAddress());
        address apiDaoAddress = daoFactory.generateAPIDao(apiDetails, daoAndTokenDetails, 
                                        votingSupportPercentage, votingMinimumApprovalPercentage, 
                                        voteDuration, apiTokenAddress);
        
        platfrom.apiDAOCreated(msg.sender, address(apiDaoAddress), address(apiTokenAddress));
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