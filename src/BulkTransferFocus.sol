// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 <0.8.19;

import "openzeppelin/token/ERC721/IERC721.sol";

/**
 * @title BulkTransfer
 * @dev Bulk transfer Tokens & NFTs
 * @author Filipe Pina <fopina@skmobi.com>  
 */
 contract BulkTransferFocus {
    struct Call {
        address to;
        uint16 amountOrTokenId;
    }

    IERC721 private target;
    
    constructor(address _target) {
        target = IERC721(_target);
    }

    /**
     * @dev Transfer ERC721 token to different recipients
     * @param calls an array of Call structs
     */
    function bulkTransfer721(Call[] calldata calls) public {
        uint256 length = calls.length;
        Call calldata call;
        for (uint256 i = 0; i < length;) {
            call = calls[i];
            target.transferFrom(msg.sender, call.to, call.amountOrTokenId);
            unchecked { ++i; }
        }
    }

    /**
     * @dev Transfer ERC721 token to the same recipient
     * @param to token contract address
     * @param tokenIds an array of Call structs
     */
    function bulkTransfer721Lite(address to, uint16[] calldata tokenIds) public {
        uint256 length = tokenIds.length;
        uint16 tokenId;
        for (uint16 i = 0; i < length;) {
            tokenId = tokenIds[i];
            target.transferFrom(msg.sender, to, tokenId);
            unchecked { ++i; }
        }
    }
}
