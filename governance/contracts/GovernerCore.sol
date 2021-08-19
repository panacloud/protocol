// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract GovernerCore {

    // Governance Configuration

    // @notice The delay before voting on a proposal may take place, once proposed
    uint public votingDelay = 1; // 1 block

    // @notice The duration of voting on a proposal, in blocks
    uint public votingPeriod = 17280; // ~3 days in blocks (assuming 15s blocks)
    
    // @notice The number of votes required in order for a voter to become a proposer
    uint public proposalThreshold = 100000e18; // 100,000 = 1% of Token
    
    // @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    uint public quorumVotes = 400000e18; // 400,000 = 4% of Token

    // @notice Initial proposal id set at become
    uint public initialProposalId;
    
    // @notice The total number of proposals
    uint public proposalCount;

    // @notice The official record of all proposals ever proposed
    mapping (uint => Proposal) public proposals;

    // @notice The latest proposal for each proposer
    mapping (address => uint) public latestProposalIds;

    // Just for the example if we want to have working around of nested mapping error of struct
    // uint -- Proposal Id
    //mapping(uint=>mapping(address=>Receipt)) receipts;

    struct Proposal {
        // @notice Unique id for looking up a proposal
        uint id;

        // @notice Creator of the proposal
        address proposer;

        // @notice The timestamp that the proposal will be available for execution, set once the vote succeeds
        uint eta;

        // @notice API Details
        APIProposalDetails apiDetails;

        // @notice The block at which voting begins: holders must delegate their votes prior to this block
        uint startBlock;

        // @notice The block at which voting ends: votes must be cast prior to this block
        uint endBlock;

        // @notice Current number of votes in favor of this proposal
        uint forVotes;

        // @notice Current number of votes in opposition to this proposal
        uint againstVotes;

        // @notice Current number of votes for abstaining for this proposal
        uint abstainVotes;

        // @notice Flag marking whether the proposal has been canceled
        bool canceled;

        // @notice Flag marking whether the proposal has been executed
        bool executed;

        // @notice Receipts of ballots for the entire set of voters
        mapping (address => Receipt) receipts;
    }

    struct APIProposalDetails {
        // @notice Title of API which is being proposed
        string apiTitle;

        // @notice List of high level features that will be included in API
        string[] highLevelFeatures;

        // @notice URL for further details about API
        string documentationURL;

        // @notice Complete in depth details about the purpose of API, its usage and 
        string description;
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        // @notice Whether or not a vote has been cast
        bool hasVoted;

        // @notice Whether or not the voter supports the proposal or abstains
        uint8 support;

        // @notice The number of votes the voter had, which were cast
        uint96 votes;
    }

    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

}