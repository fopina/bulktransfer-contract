// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BulkTransferFocus.sol";
import "./mocks/MockERC721.sol";

address constant ADDR1 = 0x0000000000000000000000000000000000000001;
address constant ADDR2 = 0x0000000000000000000000000000000000000002;
address constant ADDR3 = 0x0000000000000000000000000000000000000003;
address constant ADDR4 = 0x0000000000000000000000000000000000000004;
uint256 constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
uint256 constant TEST_AMOUNT = 1000000000000000000;

contract BulkTransferFocusTest is Test {
    BulkTransferFocus bulkTransfer;
    MockERC721 callee721;
    

    function setUp() public {
        callee721 = new MockERC721();
        bulkTransfer = new BulkTransferFocus(address(callee721));

        for (uint256 j = 1; j != 10; j ++) {
            callee721.safeMint(ADDR1, j);
        }
    }

    function testTransfer721InvalidToken() public {
        BulkTransferFocus.Call[] memory calls = new BulkTransferFocus.Call[](1);
        calls[0] = BulkTransferFocus.Call(ADDR2, 9999);
        vm.expectRevert(bytes("ERC721: invalid token ID"));
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(calls);
    }

    function testTransfer721NotApproved() public {
        BulkTransferFocus.Call[] memory calls = new BulkTransferFocus.Call[](1);
        calls[0] = BulkTransferFocus.Call(ADDR2, 1);
        vm.expectRevert(bytes("ERC721: caller is not token owner or approved"));
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(calls);
    }

    function testTransfer721() public {
        vm.startPrank(ADDR1);
        callee721.setApprovalForAll(address(bulkTransfer), true);
        BulkTransferFocus.Call[] memory calls = new BulkTransferFocus.Call[](1);
        calls[0] = BulkTransferFocus.Call(ADDR2, 1);
        bulkTransfer.bulkTransfer721(calls);
        vm.stopPrank();
    }

    function testTransfer721Lite() public {
        vm.startPrank(ADDR1);
        callee721.setApprovalForAll(address(bulkTransfer), true);
        uint16[] memory calls = new uint16[](1);
        calls[0] = 1;
        bulkTransfer.bulkTransfer721Lite(ADDR2, calls);
        vm.stopPrank();
    }

    function testTransfer721LiteFailPartial() public {
        vm.startPrank(ADDR1);
        callee721.setApprovalForAll(address(bulkTransfer), true);
        uint16[] memory calls = new uint16[](2);
        calls[0] = 1;
        calls[1] = 9999;
        vm.expectRevert(bytes("ERC721: invalid token ID"));
        bulkTransfer.bulkTransfer721Lite(ADDR2, calls);
        vm.stopPrank();
        // no tokens changed owner
        assertEq(callee721.balanceOf(ADDR1), 9);
    }
}

// re-do some tests for clean gas report
contract BulkTransferFocusGasTest is Test {
    BulkTransferFocus bulkTransfer;
    MockERC721 callee721;

    function setUp() public {
        callee721 = new MockERC721();
        bulkTransfer = new BulkTransferFocus(address(callee721));

        // do all funding and approval in setUp for cleaner gas reports
        for (uint256 j = 1; j != 10; j ++) {
            callee721.safeMint(ADDR1, j);
        }

        vm.prank(ADDR1);
        callee721.setApprovalForAll(address(bulkTransfer), true);
    }

    function testGasTransfer721() public {
        BulkTransferFocus.Call[] memory calls = new BulkTransferFocus.Call[](1);
        calls[0] = BulkTransferFocus.Call(ADDR2, 1);
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(calls);
    }

    function testGasTransfer721Scale() public {
        BulkTransferFocus.Call[] memory calls = new BulkTransferFocus.Call[](3);
        calls[0] = BulkTransferFocus.Call(ADDR2, 1);
        calls[1] = BulkTransferFocus.Call(ADDR3, 2);
        calls[2] = BulkTransferFocus.Call(ADDR4, 3);
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(calls);
    }

    function testGasTransfer721Lite() public {
        uint16[] memory calls = new uint16[](1);
        calls[0] = 1;
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721Lite(ADDR2, calls);
    }

    function testGasTransfer721LiteScale() public {
        uint16[] memory calls = new uint16[](3);
        calls[0] = 1;
        calls[1] = 2;
        calls[2] = 3;
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721Lite(ADDR2, calls);
    }
}
