// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/security/Pausable.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC721/extensions/ERC721Burnable.sol";

contract MockERC721 is ERC721, Pausable, Ownable, ERC721Burnable {
    constructor() ERC721("Test NFT", "TSTNFT") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
