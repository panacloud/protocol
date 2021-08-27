// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./GovernerCore.sol";
import "./GovernerEvents.sol";
import "./PanaFactory.sol";
import "./GovernerInterfaces.sol";

contract PlatformGoverner is GovernerCore, GovernerEvents, Ownable {

    string public constant name = "Panacloud Governor Bravo";

    PanaFactory panaFactory;

    // @notice The minimum setable proposal threshold
    uint public constant MIN_PROPOSAL_THRESHOLD = 100e18; // 100 PanaCoin

    // @notice The maximum setable proposal threshold
    uint public constant MAX_PROPOSAL_THRESHOLD = 2000e18; //2000 PanaCoin

    // @notice The minimum setable voting period
    uint public constant MIN_VOTING_PERIOD = 5760; // About 24 hours

    // @notice The max setable voting period
    uint public constant MAX_VOTING_PERIOD = 80640; // About 2 weeks

    // @notice The min setable voting delay
    uint public constant MIN_VOTING_DELAY = 1;

    // @notice The max setable voting delay
    uint public constant MAX_VOTING_DELAY = 40320; // About 1 week

    TimelockInterface timelock;
    PanaCoinInterface panacoin;

    // Implement further, add more initialization properties, add upgradation, add timelock?


    function initialize(address _panaFactory, address _timelock, address _panacoin) public onlyOwner {
        require(address(panaFactory) == address(0), "Panacloud GovernorBravo::initialize: can only initialize once");
        
        require(address(timelock) == address(0), "Panacloud GovernorBravo::initialize: can only initialize once");
        //require(msg.sender == admin, "GovernorBravo::initialize: admin only");
        require(_timelock != address(0), "Panacloud GovernorBravo::initialize: invalid timelock address");
        require(_panacoin != address(0), "Panacloud GovernorBravo::initialize: invalid comp address");

        panaFactory = PanaFactory(_panaFactory);
        timelock = TimelockInterface(_timelock);
        panacoin = PanaCoinInterface(_panacoin);

        proposalThreshold = 500e18;
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
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < this.quorumVotes()) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.timestamp >= add256(proposal.eta, timelock.GRACE_PERIOD())) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

    

    // IMPORTANT
    // https://docs.soliditylang.org/en/v0.7.0/types.html?highlight=struct#structs
    // https://ethereum.stackexchange.com/questions/87451/solidity-error-struct-containing-a-nested-mapping-cannot-be-constructed
    // Struct with nesting mapping is allowed only if used as storage, if we try to create
    // Struct instance locally in function then it will not allow because of the mapping inside struct
    function propose(string memory apiTitle, string[] memory highLevelFeatures,
                    string memory documentationURL,string memory description) public returns (uint){
        
        require(panacoin.getPriorVotes(msg.sender, sub256(block.number, 1)) > proposalThreshold, "PanacloudGovernorBravo::propose: proposer votes below proposal threshold");
        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = this.state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "PanacloudGovernorBravo::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "PanacloudGovernorBravo::propose: one live proposal per proposer, found an already pending proposal");
        }

        uint startBlock = add256(block.number, this.votingDelay());
        uint endBlock = add256(startBlock, this.votingPeriod());

        proposalCount++;

        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.proposer = msg.sender;
        newProposal.eta = 0;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.forVotes = 0;
        newProposal.againstVotes = 0;
        newProposal.abstainVotes = 0;
        newProposal.canceled = false;
        newProposal.executed = false;
        newProposal.apiDetails = APIProposalDetails({
            apiTitle: apiTitle,
            highLevelFeatures: highLevelFeatures,
            documentationURL: documentationURL,
            description: description
        });

        latestProposalIds[newProposal.proposer] = newProposal.id;
        emit ProposalCreated(newProposal.id, msg.sender, apiTitle, highLevelFeatures, documentationURL, description, startBlock, endBlock);
        return newProposal.id;
        
        /*
        // Not allowed if we have mapping inside struct
        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            eta: 0,
            startBlock: startBlock,
            endBlock: endBlock,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            canceled: false,
            executed: false,
            apiDetails: APIProposalDetails({
                apiTitle: apiTitle,
                highLevelFeatures: highLevelFeatures,
                documentationURL: documentationURL,
                description: description
            })
        });
        */
    }

    function queue(uint proposalId) external {
        require(state(proposalId) == ProposalState.Succeeded, "GovernorBravo::queue: proposal can only be queued if it is succeeded");
        Proposal storage proposal = proposals[proposalId];
        uint eta = add256(block.timestamp, timelock.delay());

        //timelock.queueTransaction(target, value, signature, data, eta);

        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

    function execute(uint proposalId) external payable {
        require(state(proposalId) == ProposalState.Queued, "PanacloudGovernorBravo::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        
        uint256 tokinId = panaFactory.generateAPIIdeaNFT(proposal.proposer);

        // To do
        //timelock.executeTransaction.value(proposal.values[i])(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint proposalId) external {
        require(state(proposalId) != ProposalState.Executed, "PanacloudGovernorBravo::cancel: cannot cancel executed proposal");

        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer || panacoin.getPriorVotes(proposal.proposer, sub256(block.number, 1)) < proposalThreshold, "PanacloudGovernorBravo::cancel: proposer above threshold");

        proposal.canceled = true;
        
        // To do
        /*
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.cancelTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }
        */
        emit ProposalCanceled(proposalId);
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

    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint256) {
        require(state(proposalId) == ProposalState.Active, "PanacloudGovernorBravo::castVoteInternal: voting is closed");
        require(support <= 2, "PanacloudGovernorBravo::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "PanacloudGovernorBravo::castVoteInternal: voter already voted");
        uint256 votes = panacoin.getPriorVotes(voter, proposal.startBlock);

        if (support == 0) {
            proposal.againstVotes = add256(proposal.againstVotes, votes);
        } else if (support == 1) {
            proposal.forVotes = add256(proposal.forVotes, votes);
        } else if (support == 2) {
            proposal.abstainVotes = add256(proposal.abstainVotes, votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }
    /// start from here now
    

    function add256(uint256 a, uint256 b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }

}