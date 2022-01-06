// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../governance/GovernorInterfaces.sol";
import "../governance/GovernorEvents.sol";
import "./APIGovernorInterfaces.sol";
import "./APIGovernorCore.sol";

contract APIDao is APIGovernorCore, GovernorEvents, Ownable {

    // @notice The minimum setable proposal threshold
    uint public constant MIN_PROPOSAL_THRESHOLD_PERCENT = 5000; // 0.50% of circulating supply : In ten-thosandaths 5000 = 0.50%

    // @notice The maximum setable proposal threshold
    uint public constant MAX_PROPOSAL_THRESHOLD_PERCENT = 20000; // 2.00% of circulating supply : In ten-thosandaths 20000 = 2.00%

    // @notice The minimum setable voting period
    uint public constant MIN_VOTING_PERIOD = 5760; // About 24 hours

    // @notice The max setable voting period
    uint public constant MAX_VOTING_PERIOD = 80640; // About 2 weeks

    // @notice The min setable voting delay
    uint public constant MIN_VOTING_DELAY = 1; // 1 block

    // @notice The max setable voting delay
    uint public constant MAX_VOTING_DELAY = 40320; // 40320 block means about 1 week 

    // @notice The minimum setable proposal threshold
    uint public constant MIN_QUORUM_VOTES_PERCENT = 30000; // 3.00% of circulating supply : In ten-thosandaths 30000 = 3.00%

    // @notice The maximum setable proposal threshold
    uint public constant MAX_QUORUM_VOTES_PERCENT = 100000; // 10.00% of circulating supply : In ten-thosandaths 100000 = 10.00%

    /// @notice The maximum number of actions that can be included in a proposal
    uint public constant proposalMaxOperations = 10; // 10 actions

    //Still need to explore EIP-712 for 'DOMAIN_TYPEHASH' and 'BALLOT_TYPEHASH'
    // @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    // @notice The EIP-712 typehash for the ballot struct used by the contract
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");

    /// @notice Emitted when quorum votes is set
    event QuorumVotesSet(uint oldQuorumVotesPercent, uint newQuorumVotesPercent);

    TimelockInterface timelock;
    APITokenInterface apiToken;

    string public apiProposalId;
    string public apiID;
    string public name = "Panacloud API DAO";
    address public apiTokenAddress;
    bool public isProposalExists;

    /*
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
    */
    function initialize(address _timelock, address _apiToken, uint _votingPeriod, uint _votingDelay, 
                uint _proposalThresholdPercent, uint _quorumVotesPercent, string memory _apiProposalId, 
                string memory _apiID, string memory _daoName) public onlyAdmin {
        require(address(timelock) == address(0), "APIGovernor::initialize: can only initialize once");
        // Not needed at this point as already used onlyAdmin modifier
        //require(msg.sender == admin, "PanaGovernor::initialize: admin only");
        require(_timelock != address(0), "APIGovernor::initialize: invalid timelock address");
        require(_apiToken != address(0), "APIGovernor::initialize: invalid API Token address");
        require(_votingPeriod >= MIN_VOTING_PERIOD && _votingPeriod <= MAX_VOTING_PERIOD, "APIGovernor::initialize: invalid voting period");
        require(_votingDelay >= MIN_VOTING_DELAY && _votingDelay <= MAX_VOTING_DELAY, "APIGovernor::initialize: invalid voting delay");
        require(_proposalThresholdPercent >= MIN_PROPOSAL_THRESHOLD_PERCENT && _proposalThresholdPercent <= MAX_PROPOSAL_THRESHOLD_PERCENT, "APIGovernor::initialize: invalid proposal threshold");
        require(_quorumVotesPercent >= MIN_QUORUM_VOTES_PERCENT && _quorumVotesPercent <= MAX_QUORUM_VOTES_PERCENT, "APIGovernor::initialize: invalid proposal quorum");
        require((bytes(_apiID)).length > 0,"APIGovernor::initialize: invalid api id");
        require((bytes(_daoName)).length > 0,"APIGovernor::initialize: invalid DAO name");

        timelock = TimelockInterface(_timelock);
        apiToken = APITokenInterface(_apiToken);

        votingPeriod = _votingPeriod;
        votingDelay = _votingDelay;
        proposalThresholdPercent = _proposalThresholdPercent;
        quorumVotesPercent = _quorumVotesPercent;

        apiProposalId = _apiProposalId;
        isProposalExists = (bytes(_apiProposalId)).length > 0? true: false;
        apiID = _apiID;
        name = _daoName;
    }

    // IMPORTANT
    // https://docs.soliditylang.org/en/v0.7.0/types.html?highlight=struct#structs
    // https://ethereum.stackexchange.com/questions/87451/solidity-error-struct-containing-a-nested-mapping-cannot-be-constructed
    // Struct with nesting mapping is allowed only if used as storage, if we try to create
    // Struct instance locally in function then it will not allow because of the mapping inside struct
    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) public returns (uint) {
        
        // Allow addresses above proposal threshold and whitelisted addresses to propose
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.. need to correc this percent to number
        require(apiToken.getPriorVotes(msg.sender, (block.number - 1)) > proposalThresholdPercent || isWhitelisted(msg.sender), "APIGovernor::propose: proposer votes below proposal threshold");
        require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "APIGovernor::propose: proposal function information arity mismatch");
        require(targets.length != 0, "APIGovernor::propose: must provide actions");
        require(targets.length <= proposalMaxOperations, "APIGovernor::propose: too many actions");

        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "APIGovernor::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "APIGovernor::propose: one live proposal per proposer, found an already pending proposal");
        }

        uint startBlock = block.number + votingDelay;
        uint endBlock = startBlock + votingPeriod;

        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.proposer = msg.sender;
        newProposal.eta = 0;
        newProposal.targets = targets;
        newProposal.values = values;
        newProposal.signatures = signatures;
        newProposal.calldatas = calldatas;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.forVotes = 0;
        newProposal.againstVotes = 0;
        newProposal.abstainVotes = 0;
        newProposal.canceled = false;
        newProposal.executed = false;

        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(newProposal.id, msg.sender, targets, values, signatures, calldatas, startBlock, endBlock, description);
        return newProposal.id;
    }

    /**
      * @notice Queues a proposal of state succeeded
      * @param proposalId The id of the proposal to queue
      */
    function queue(uint proposalId) external {
        require(state(proposalId) == ProposalState.Succeeded, "APIGovernor::queue: proposal can only be queued if it is succeeded");
        Proposal storage proposal = proposals[proposalId];
        uint eta = block.timestamp + timelock.delay();
        for (uint i = 0; i < proposal.targets.length; i++) {
            queueOrRevertInternal(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], eta);
        }
        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

    function queueOrRevertInternal(address target, uint value, string memory signature, bytes memory data, uint eta) internal {
        require(!timelock.queuedTransactions(keccak256(abi.encode(target, value, signature, data, eta))), "APIGovernor::queueOrRevertInternal: identical proposal action already queued at eta");
        timelock.queueTransaction(target, value, signature, data, eta);
    }

    /**
      * @notice Executes a queued proposal if eta has passed
      * @param proposalId The id of the proposal to execute
      */
    function execute(uint proposalId) external payable {
        require(state(proposalId) == ProposalState.Queued, "APIGovernor::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            // https://vomtom.at/solidity-0-6-4-and-call-value-curly-brackets/
            // https://ethereum.stackexchange.com/questions/82412/using-value-is-deprecated-use-value-instead
            timelock.executeTransaction{value:proposal.values[i]}(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }
        emit ProposalExecuted(proposalId);
    }

    /**
      * @notice Cancels a proposal only if sender is the proposer, or proposer delegates dropped below proposal threshold
      * @param proposalId The id of the proposal to cancel
      */
    function cancel(uint proposalId) external {
        require(state(proposalId) != ProposalState.Executed, "APIGovernor::cancel: cannot cancel executed proposal");

        Proposal storage proposal = proposals[proposalId];

        // Proposer can cancel
        if(msg.sender != proposal.proposer) {
            // Whitelisted proposers can't be canceled for falling below proposal threshold
            if(isWhitelisted(proposal.proposer)) {
                //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.. need to correc this percent to number
                require((apiToken.getPriorVotes(proposal.proposer, (block.number - 1)) < proposalThresholdPercent) && msg.sender == whitelistGuardian, "APIGovernor::cancel: whitelisted proposer");
            }
            else {
                //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.. need to correc this percent to number
                require((apiToken.getPriorVotes(proposal.proposer, (block.number - 1)) < proposalThresholdPercent), "APIGovernor::cancel: proposer above threshold");
            }
        }
        
        proposal.canceled = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.cancelTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }

        emit ProposalCanceled(proposalId);
    }

    /**
      * @notice Gets actions of a proposal
      * @param proposalId the id of the proposal
      * @return Targets, values, signatures, and calldatas of the proposal actions
      */
    function getActions(uint proposalId) external view returns (address[] memory, uint[] memory, string[] memory, bytes[] memory) {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    /**
      * @notice Gets the receipt for a voter on a given proposal
      * @param proposalId the id of proposal
      * @param voter The address of the voter
      * @return The voting receipt
      */
    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory) {
        return proposals[proposalId].receipts[voter];
    }

    /**
      * @notice Gets the state of a proposal
      * @param proposalId The id of the proposal
      * @return Proposal state
      */
    function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > 0, "APIGovernor::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
            //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.. need to correc this percent to number
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorumVotesPercent) {
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

    function castVote(uint proposalId, uint8 support) external {
        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), "");
    }

    function castVoteWithReason(uint proposalId, uint8 support, string calldata reason) external {
        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), reason);
    }

    function castVoteBySig(uint proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainIdInternal(), address(this)));
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "APIGovernor::castVoteBySig: invalid signature");
        emit VoteCast(signatory, proposalId, support, castVoteInternal(signatory, proposalId, support), "");
    }

    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint256) {
        require(state(proposalId) == ProposalState.Active, "APIGovernor::castVoteInternal: voting is closed");
        require(support <= 2, "APIGovernor::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "APIGovernor::castVoteInternal: voter already voted");
        uint256 votes = apiToken.getPriorVotes(voter, proposal.startBlock);

        if (support == 0) {
            proposal.againstVotes = (proposal.againstVotes + votes);
        } else if (support == 1) {
            proposal.forVotes = (proposal.forVotes + votes);
        } else if (support == 2) {
            proposal.abstainVotes = (proposal.abstainVotes + votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }

    /**
     * @notice View function which returns if an account is whitelisted
     * @param account Account to check white list status of
     * @return If the account is whitelisted
     */
    function isWhitelisted(address account) public view returns (bool) {
        return (whitelistAccountExpirations[account] > block.timestamp);
    }

    function setVotingDelay(uint newVotingDelay) external onlyAdmin {
        require(newVotingDelay >= MIN_VOTING_DELAY && newVotingDelay <= MAX_VOTING_DELAY, "APIGovernor::setVotingDelay: invalid voting delay");
        uint oldVotingDelay = votingDelay;
        votingDelay = newVotingDelay;

        emit VotingDelaySet(oldVotingDelay,votingDelay);
    }

    function setVotingPeriod(uint newVotingPeriod) external onlyAdmin {
        require(newVotingPeriod >= MIN_VOTING_PERIOD && newVotingPeriod <= MAX_VOTING_PERIOD, "APIGovernor::setVotingPeriod: invalid voting period");
        uint oldVotingPeriod = votingPeriod;
        votingPeriod = newVotingPeriod;

        emit VotingPeriodSet(oldVotingPeriod, votingPeriod);
    }

    function setProposalThreshold(uint newProposalThreshold) external onlyAdmin {
        require(newProposalThreshold >= MIN_PROPOSAL_THRESHOLD_PERCENT && newProposalThreshold <= MAX_PROPOSAL_THRESHOLD_PERCENT, "APIGovernor::setProposalThreshold: invalid proposal threshold");
        uint oldProposalThreshold = proposalThresholdPercent;
        proposalThresholdPercent = newProposalThreshold;

        emit ProposalThresholdSet(oldProposalThreshold, proposalThresholdPercent);
    }

    function setQuorumVotes(uint newQuorumVotesPercent) external onlyAdmin {
        require(newQuorumVotesPercent >= MIN_PROPOSAL_THRESHOLD_PERCENT && newQuorumVotesPercent <= MAX_PROPOSAL_THRESHOLD_PERCENT, "APIGovernor::setQuorumVotes: invalid quorum votes");
        uint oldQuorumVotesPercent = quorumVotesPercent;
        quorumVotesPercent = newQuorumVotesPercent;

        emit QuorumVotesSet(oldQuorumVotesPercent, quorumVotesPercent);
    }

    /**
     * @notice Admin function for setting the whitelist expiration as a timestamp for an account. Whitelist status allows accounts to propose without meeting threshold
     * @param account Account address to set whitelist expiration for
     * @param expiration Expiration for account whitelist status as timestamp (if now < expiration, whitelisted)
     */
    function setWhitelistAccountExpiration(address account, uint expiration) external {
        require(msg.sender == admin || msg.sender == whitelistGuardian, "APIGovernor::setWhitelistAccountExpiration: admin only");
        whitelistAccountExpirations[account] = expiration;

        emit WhitelistAccountExpirationSet(account, expiration);
    }

    /**
     * @notice Admin function for setting the whitelistGuardian. WhitelistGuardian can cancel proposals from whitelisted addresses
     * @param account Account to set whitelistGuardian to (0x0 to remove whitelistGuardian)
     */
    function setWhitelistGuardian(address account) external onlyAdmin {
        //require(msg.sender == admin, "PanaGovernor::setWhitelistGuardian: admin only");
        address oldGuardian = whitelistGuardian;
        whitelistGuardian = account;

        emit WhitelistGuardianSet(oldGuardian, whitelistGuardian);
    }

    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      */
    function setPendingAdmin(address newPendingAdmin) external onlyAdmin {
        // Check caller = admin
        //require(msg.sender == admin, "PanaGovernor:setPendingAdmin: admin only");

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
        require(msg.sender == pendingAdmin && msg.sender != address(0), "APIGovernor:acceptAdmin: pending admin only");

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