// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface APITokenInterface {
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
}