// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract APINFT is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("APINFT", "APT") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://www.panacloud.com/";
    }

    function safeMint(address to) public onlyOwner returns(uint256) {
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());
        return _tokenIdCounter.current();
    }
}