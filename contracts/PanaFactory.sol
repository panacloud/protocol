// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APINFT.sol";

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

    function generateAPIIdeaNFT(address ideaOwnerAddress) public onlyOwner returns(uint256) {
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

    struct Receipt {
        // @notice Whether or not a vote has been cast
        bool hasVoted;

        // @notice Whether or not the voter supports the proposal or abstains
        uint8 support;

        // @notice The number of votes the voter had, which were cast
        uint256 votes;
        
    }

    function generateAPIDao(string[] memory apiDetails, string[] memory daoAndTokenDetails,
        int256 maxApiTokenSupply, int256 initialApiTokenSupply, int8 developerSharePercentage,
        int8 apiInvestorSharePercentage, uint8 votingSupportPercentage, 
        uint8 votingMinimumApprovalPercentage, uint256 voteDuration) public {

    }

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