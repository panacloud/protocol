// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./governance/GovernerInterfaces.sol";

contract APIDao is Ownable {

    // @notice The minimum setable proposal threshold
    uint public constant MIN_PROPOSAL_THRESHOLD = 100e18; // 100 API Token

    // @notice The maximum setable proposal threshold
    uint public constant MAX_PROPOSAL_THRESHOLD = 2000e18; //2000 API Token

    // @notice The minimum setable voting period
    uint public constant MIN_VOTING_PERIOD = 5760; // About 24 hours

    // @notice The max setable voting period
    uint public constant MAX_VOTING_PERIOD = 80640; // About 2 weeks

    // @notice The min setable voting delay
    uint public constant MIN_VOTING_DELAY = 1; // 1 block

    // @notice The max setable voting delay
    uint public constant MAX_VOTING_DELAY = 40320; // 40320 block means about 1 week 

    //Still need to explore EIP-712 for 'DOMAIN_TYPEHASH' and 'BALLOT_TYPEHASH'
    // @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    // @notice The EIP-712 typehash for the ballot struct used by the contract
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");

    // @notice The delay before voting on a proposal may take place, once proposed
    uint public votingDelay = 1; // 1 block

    // @notice The duration of voting on a proposal, in blocks
    uint public votingPeriod = 17280; // ~3 days in blocks (assuming 15s blocks)
    
    // @notice The number of votes required in order for a voter to become a proposer
    uint public proposalThresholdPercentage = 1; // 1 % of circulating supply of API Token
    
    // @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    uint public quorumVotesPercentage = 40; // 40% of total votes casted with API Token

    // @notice Initial proposal id set at become
    uint public initialProposalId;
    
    // @notice The total number of proposals
    uint public proposalCount;

    // @notice The official record of all proposals ever proposed
    mapping (uint => Proposal) public proposals;

    // @notice The latest proposal for each proposer
    mapping (address => uint) public latestProposalIds;

    // @notice Minimum Approval is the percentage of the total token supply 
    // that is required to vote “Yes” on a proposal before it can be approved. For example, if 
    // the “Minimum Approval” is set to 20%, then more than 20% of the outstanding token supply 
    // must vote “Yes” on a proposal for it to pass.
    uint public minimumApprovalPercentage = 10; // 10 % of circulating supply of API Token

    address public admin;
    address public pendingAdmin;

    TimelockInterface timelock;
    // More parameters will be added based on requirement of 
    event ProposalCreated(uint id, address proposer, string apiTitle, string description, uint startBlock, uint endBlock);

    /// @param support Support value for the vote. 0=against, 1=for, 2=abstain
    event VoteCast(address indexed voter, uint proposalId, uint8 support, uint votes, string reason);

    event ProposalCanceled(uint id);
    event ProposalQueued(uint id, uint eta);
    event ProposalExecuted(uint id);
    event VotingDelaySet(uint oldVotingDelay, uint newVotingDelay);
    event VotingPeriodSet(uint oldVotingPeriod, uint newVotingPeriod);
    event ProposalThresholdSet(uint oldProposalThreshold, uint newProposalThreshold);

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);

    string public apiProposalId;
    string public apiID;
    string public name = "APIDao";
    address public apiTokenAddress;
    bool public isProposalExists;

    constructor(string memory _apiProposalId, string memory _apiID, string memory _daoName, 
                uint256 _quorumVotesPercentage, uint256 _minimumApprovalPercentage, uint256 voteDuration, 
                address _apiTokenAddress) {
        admin = msg.sender;
        apiProposalId = _apiProposalId;
        apiID = _apiID;
        name = _daoName;
        quorumVotesPercentage = _quorumVotesPercentage;
        minimumApprovalPercentage = _minimumApprovalPercentage;
        votingPeriod = voteDuration;
        apiTokenAddress = _apiTokenAddress;
        isProposalExists = (bytes(_apiProposalId)).length > 0? true: false;
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "API DAO Governor: caller is not the Admin");
        _;
    }

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

    // This needs to be change according to requirements
    struct APIProposalDetails {
        // @notice Title of API which is being proposed
        string apiTitle;

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
        uint256 votes;
        
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



    function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > 0, "Panacloud GovernorBravo::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < this.quorumVotesPercentage()) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.timestamp >= (proposal.eta + timelock.GRACE_PERIOD())) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory) {
        return proposals[proposalId].receipts[voter];
    }

    function castVote(uint proposalId, uint8 support) external {
        uint256 votes = castVoteInternal(msg.sender, proposalId, support);
        emit VoteCast(msg.sender, proposalId, support, votes, "");
    }

    function castVoteWithReason(uint proposalId, uint8 support, string calldata reason) external {
        uint256 votes = castVoteInternal(msg.sender, proposalId, support);
        emit VoteCast(msg.sender, proposalId, support, votes, reason);
    }

    function castVoteBySig(uint proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainIdInternal(), address(this)));
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GovernorBravo::castVoteBySig: invalid signature");
        emit VoteCast(signatory, proposalId, support, castVoteInternal(signatory, proposalId, support), "");
    }

    // IMPORTANT: Need to fix 6th link of this function where we need to get votes from Token
    // For now we are using constact 100 votes
    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint256) {
        require(state(proposalId) == ProposalState.Active, "PanacloudGovernorBravo::castVoteInternal: voting is closed");
        require(support <= 2, "PanacloudGovernorBravo::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "PanacloudGovernorBravo::castVoteInternal: voter already voted");
        uint256 votes = 100; //panacoin.getPriorVotes(voter, proposal.startBlock);

        if (support == 0) {
            proposal.againstVotes = proposal.againstVotes + votes;
        } else if (support == 1) {
            proposal.forVotes = proposal.forVotes + votes;
        } else if (support == 2) {
            proposal.abstainVotes = proposal.abstainVotes + votes;
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }


    function setVotingDelay(uint newVotingDelay) external {
        require(msg.sender == admin, "Panacloud API GovernorBravo::setVotingDelay: admin only");
        require(newVotingDelay >= MIN_VOTING_DELAY && newVotingDelay <= MAX_VOTING_DELAY, "API GovernorBravo::_setVotingDelay: invalid voting delay");
        uint oldVotingDelay = votingDelay;
        votingDelay = newVotingDelay;

        emit VotingDelaySet(oldVotingDelay,votingDelay);
    }

    function setVotingPeriod(uint newVotingPeriod) external {
        require(msg.sender == admin, "Panacloud API GovernorBravo::setVotingPeriod: admin only");
        require(newVotingPeriod >= MIN_VOTING_PERIOD && newVotingPeriod <= MAX_VOTING_PERIOD, "API GovernorBravo::_setVotingPeriod: invalid voting period");
        uint oldVotingPeriod = votingPeriod;
        votingPeriod = newVotingPeriod;

        emit VotingPeriodSet(oldVotingPeriod, votingPeriod);
    }

    function setProposalThreshold(uint newProposalThresholdPercentage) external {
        require(msg.sender == admin, "Panacloud API GovernorBravo::setProposalThreshold: admin only");
        require(newProposalThresholdPercentage >= MIN_PROPOSAL_THRESHOLD && newProposalThresholdPercentage <= MAX_PROPOSAL_THRESHOLD, "API GovernorBravo::_setProposalThreshold: invalid proposal threshold");
        uint oldProposalThresholdPercentage = proposalThresholdPercentage;
        proposalThresholdPercentage = newProposalThresholdPercentage;

        emit ProposalThresholdSet(oldProposalThresholdPercentage, proposalThresholdPercentage);
    }

    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      */
    function setPendingAdmin(address newPendingAdmin) external {
        // Check caller = admin
        require(msg.sender == admin, "Panacloud API GovernorBravo::setPendingAdmin: admin only");

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    /**
      * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
      * @dev Admin function for pending admin to accept role and update admin
      */
    function acceptAdmin() external {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        require(msg.sender == pendingAdmin && msg.sender != address(0), "Panacloud API GovernorBravo::acceptAdmin: pending admin only");

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function getChainIdInternal() internal view returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

} 