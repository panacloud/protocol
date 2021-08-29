// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract GovernerEvents {

    event ProposalCreated(uint id, address proposer, string apiTitle, string[] highLevelFeatures, string documentationURL, string description, uint startBlock, uint endBlock);

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
}