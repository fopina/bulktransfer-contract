// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 <0.8.19;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC721/IERC721.sol";

/**
 * @title BulkTransfer
 * @dev Bulk transfer Tokens & NFTs
 * @author Filipe Pina <fopina@skmobi.com>  
 */
 contract BulkTransfer {
    struct Call {
        address to;
        uint256 amountOrTokenId;
    }

    /**
     * @dev Transfer ERC20 token to different recipients
     * @param token token contract address
     * @param calls an array of Call structs
     */
    function bulkTransfer20(address token, Call[] calldata calls) public {
        uint256 length = calls.length;
        Call calldata call;
        for (uint256 i = 0; i < length;) {
            bool success;
            call = calls[i];
            success = IERC20(token).transferFrom(msg.sender, call.to, call.amountOrTokenId);
            require(success, "bulkTransfer: call failed");
            unchecked { ++i; }
        }
    }

    /**
     * @dev Transfer ERC721 token to different recipients
     * @param token token contract address
     * @param calls an array of Call structs
     */
    function bulkTransfer721(address token, Call[] calldata calls) public {
        uint256 length = calls.length;
        Call calldata call;
        for (uint256 i = 0; i < length;) {
            call = calls[i];
            IERC721(token).transferFrom(msg.sender, call.to, call.amountOrTokenId);
            unchecked { ++i; }
        }
    }

    /**
     * @dev Transfer ERC721 token to the same recipient
     * @param token token contract address
     * @param to token contract address
     * @param tokenIds an array of Call structs
     */
    function bulkTransfer721Lite(address token, address to, uint256[] calldata tokenIds) public {
        uint256 length = tokenIds.length;
        uint256 tokenId;
        for (uint256 i = 0; i < length;) {
            tokenId = tokenIds[i];
            IERC721(token).transferFrom(msg.sender, to, tokenId);
            unchecked { ++i; }
        }
    }
}
