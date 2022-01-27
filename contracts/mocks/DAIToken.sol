// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Main ERC20 Token for Panacloud which will be used for Platform Governance DAO
 */
contract DAIToken is ERC20, Ownable {

    constructor() ERC20("Mock DAI", "MDAI") {
        // 10 million initial supply
        _mint(msg.sender, 10_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}