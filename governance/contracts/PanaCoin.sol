// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PanaCoin is ERC20 {
    
    address private _owner;
    uint256 public maxSupply = 1_000_000_000 * 10 ** decimals();

    constructor() ERC20("PanaCoin", "PCE") {
        _owner = msg.sender;
        // 10 million initial supply
        _mint(msg.sender, 10_000_000 * 10 ** decimals());
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() < maxSupply, "PanaCoin::Total Supply cannot exceed 10 billion");
        _mint(to, amount);
    }

    
}