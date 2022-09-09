// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APINFT.sol";
import "./PanacloudPlatform.sol";
import "./utils/DAOFactory.sol";
import "./utils/APITokenFactory.sol";
import "./libs/Global.sol";
import "./api-governance/APIGovernorTimelock.sol";
import "hardhat/console.sol";

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
    address private investmentPool;

    function initialize(address _panaCoin, address _apiNFT, address _panacloudPlatform, 
                        address _apiTokenFactoryAddress, address _daoFactoryAddress, 
                        address _investmentPool) public onlyOwner {
        panaCoinAddress = _panaCoin;
        apiNFTAddress = _apiNFT;
        panacloudPlatformAddress = _panacloudPlatform;
        apiTokenFactoryAddress = _apiTokenFactoryAddress;
        daoFactoryAddress = _daoFactoryAddress;
        daoFactory = DAOFactory(_daoFactoryAddress);
        apiTokenFactory = APITokenFactory(_apiTokenFactoryAddress);
        investmentPool = _investmentPool;

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

        /*
        // Need to fix msg.sender -- as API's owner will be API token factory, which is incorrect
        address apiTokenAddress = apiTokenFactory.createAPIToken(apiTokenConfig, 
                                                            platfrom.panacloudShareInAPI(),
                                                            platfrom.apiIdeaProposerShare(),
                                                            platfrom.paymentSplitterAddress());
        */
        console.log("before creating api token");
        APIToken apiToken = new APIToken(apiTokenConfig.apiTokenName,apiTokenConfig.apiTokenSymbol, apiTokenConfig.maxApiTokenSupply,
                            apiTokenConfig.initialApiTokenSupply,apiTokenConfig.developerSharePercentage,apiTokenConfig.apiInvestorSharePercentage,
                            apiTokenConfig.thresholdForSubscriberMinting, platfrom.panacloudShareInAPI(), platfrom.apiIdeaProposerShare(), platfrom.paymentSplitterAddress());
        console.log("after creating api token = ", address(apiToken));
        APIGovernorTimelock apiTimelock = new APIGovernorTimelock(msg.sender, 2 days);
        // Need to fix msg.sender -- as DAO's owner will be DAO factory, which is incorrect
        address apiDaoAddress = daoFactory.createAPIDao(address(apiTimelock), apiDAOConfig, address(apiToken));
        
        platfrom.apiDAOCreated(msg.sender, apiDAOConfig.apiId, address(apiToken), address(apiDaoAddress));
        
    }

    function mintAPITokens(address _apiToken, address to, uint256 amount) public {
        console.log("mintAPITokens start ", _apiToken);
        require(msg.sender == investmentPool, "Caller must be Investment Pool");
        console.log("mintAPITokens after required investment pool compare : pool address ", investmentPool);
        APIToken apiToken = APIToken(_apiToken);
        console.log("mintAPITokens after loading api token with address");
        require(apiToken.owner()==address(this), "Not an owner");
        console.log("mintAPITokens after required to check api token owner = ",apiToken.owner());
        apiToken.mint(to, amount);
        console.log("mintAPITokens after api token mint");
    }

    // Not being used for now -- will be removed in future if it remain unused
    function transferAPITokens(address _apiToken, address to, uint256 amount) public {
        console.log("transferAPITokens start ", _apiToken);
        require(msg.sender == investmentPool, "Caller must be Investment Pool");
        console.log("transferAPITokens after required investment pool compare : pool address ", investmentPool);
        APIToken apiToken = APIToken(_apiToken);
        console.log("transferAPITokens after loading api token with address");
        require(apiToken.owner()==address(this), "Not an owner");
        console.log("transferAPITokens after required to check api token owner = ",apiToken.owner());
        apiToken.transferFrom(investmentPool, to, amount);
        console.log("transferAPITokens after api token mint");
        //apiToken.mint(to, amount);
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