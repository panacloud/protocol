// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./GovernerCore.sol";
import "./GovernerEvents.sol";

contract PanacloudGoverner is GovernerCore, GovernerEvents {

    string public constant name = "Panacloud Governor Alpha";


    function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > 0, "Panacloud GovernorAlpha::state: invalid proposal id");
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
        // Need fix this later on
        //} else if (block.timestamp >= add256(proposal.eta, timelock.GRACE_PERIOD())) {
        } else if (block.timestamp >= add256(proposal.eta, 0)) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }

    // IMPORTANT
    // https://docs.soliditylang.org/en/v0.7.0/types.html?highlight=struct#structs
    // https://ethereum.stackexchange.com/questions/87451/solidity-error-struct-containing-a-nested-mapping-cannot-be-constructed
    // Struct with nesting mapping is allowed only if used as storage, if we try to create
    // Struct instance locally in function then it will not allow because of the mapping inside struct
    function propose(string memory apiTitle, string[] memory highLevelFeatures,
                    string memory documentationURL,string memory description) public returns (uint){
        
        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = this.state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "PanacloudGovernorAlpha::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "PanacloudGovernorAlpha::propose: one live proposal per proposer, found an already pending proposal");
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

    function castVote(uint proposalId, uint8 support) external {
        uint96 votes = castVoteInternal(msg.sender, proposalId, support);
        emit VoteCast(msg.sender, proposalId, support, votes, "");
    }

    function castVoteWithReason(uint proposalId, uint8 support, string calldata reason) external {
        uint96 votes = castVoteInternal(msg.sender, proposalId, support);
        emit VoteCast(msg.sender, proposalId, support, votes, reason);
    }

    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint96) {
        require(state(proposalId) == ProposalState.Active, "PanacloudGovernorAlpha::castVoteInternal: voting is closed");
        require(support <= 2, "PanacloudGovernorAlpha::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "PanacloudGovernorAlpha::castVoteInternal: voter already voted");
        uint96 votes = 10;//comp.getPriorVotes(voter, proposal.startBlock);

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

    function execute(uint proposalId) external payable {
        require(state(proposalId) == ProposalState.Queued, "PanacloudGovernorAlpha::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        
        // issue NFT
        // create dao for for API

        emit ProposalExecuted(proposalId);
    }

}