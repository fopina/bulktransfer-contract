// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BulkTransfer.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockERC721.sol";

address constant ADDR1 = 0x0000000000000000000000000000000000000001;
address constant ADDR2 = 0x0000000000000000000000000000000000000002;
address constant ADDR3 = 0x0000000000000000000000000000000000000003;
address constant ADDR4 = 0x0000000000000000000000000000000000000004;
uint256 constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
uint256 constant TEST_AMOUNT = 1000000000000000000;

contract BulkTransferTest is Test {
    BulkTransfer bulkTransfer;
    MockERC20 callee20;
    MockERC721 callee721;
    

    function setUp() public {
        bulkTransfer = new BulkTransfer();
        callee20 = new MockERC20();
        callee721 = new MockERC721();

        callee20.mint(ADDR1, TEST_AMOUNT);
        for (uint256 j = 1; j != 10; j ++) {
            callee721.safeMint(ADDR1, j);
        }
    }

    function testTransfer20NoAllowance() public {
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](1);
        calls[0] = BulkTransfer.Call(ADDR2, 1);
        vm.expectRevert(bytes("ERC20: insufficient allowance"));
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer20(address(callee20), calls);
    }

    function testTransfer20() public {
        vm.startPrank(ADDR1);
        callee20.approve(address(bulkTransfer), MAX_INT);

        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](1);
        calls[0] = BulkTransfer.Call(ADDR2, TEST_AMOUNT);
        bulkTransfer.bulkTransfer20(address(callee20), calls);
        vm.stopPrank();
    }

    function testTransfer20FailPartial() public {
        vm.startPrank(ADDR1);
        callee20.approve(address(bulkTransfer), MAX_INT);

        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](3);
        uint256 partialAmount = TEST_AMOUNT / 3;
        calls[0] = BulkTransfer.Call(ADDR2, partialAmount);
        calls[1] = BulkTransfer.Call(ADDR3, TEST_AMOUNT * 10);
        calls[2] = BulkTransfer.Call(ADDR4, partialAmount);
        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
        bulkTransfer.bulkTransfer20(address(callee20), calls);
        vm.stopPrank();
        assertEq(callee20.balanceOf(ADDR1), TEST_AMOUNT);
    }

    function testTransfer721InvalidToken() public {
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](1);
        calls[0] = BulkTransfer.Call(ADDR2, 99999);
        vm.expectRevert(bytes("ERC721: invalid token ID"));
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(address(callee721), calls);
    }

    function testTransfer721NotApproved() public {
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](1);
        calls[0] = BulkTransfer.Call(ADDR2, 1);
        vm.expectRevert(bytes("ERC721: caller is not token owner or approved"));
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(address(callee721), calls);
    }

    function testTransfer721() public {
        vm.startPrank(ADDR1);
        callee721.setApprovalForAll(address(bulkTransfer), true);
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](1);
        calls[0] = BulkTransfer.Call(ADDR2, 1);
        bulkTransfer.bulkTransfer721(address(callee721), calls);
        vm.stopPrank();
    }

    function testTransfer721Lite() public {
        vm.startPrank(ADDR1);
        callee721.setApprovalForAll(address(bulkTransfer), true);
        uint256[] memory calls = new uint256[](1);
        calls[0] = 1;
        bulkTransfer.bulkTransfer721Lite(address(callee721), ADDR2, calls);
        vm.stopPrank();
    }

    function testTransfer721LiteFailPartial() public {
        vm.startPrank(ADDR1);
        callee721.setApprovalForAll(address(bulkTransfer), true);
        uint256[] memory calls = new uint256[](2);
        calls[0] = 1;
        calls[1] = 9999;
        vm.expectRevert(bytes("ERC721: invalid token ID"));
        bulkTransfer.bulkTransfer721Lite(address(callee721), ADDR2, calls);
        vm.stopPrank();
        // no tokens changed owner
        assertEq(callee721.balanceOf(ADDR1), 9);
    }
}

// re-do some tests for clean gas report
contract BulkTransferGasTest is Test {
    BulkTransfer bulkTransfer;
    MockERC20 callee20;
    MockERC721 callee721;

    function setUp() public {
        bulkTransfer = new BulkTransfer();
        callee20 = new MockERC20();
        callee721 = new MockERC721();

        // do all funding and approval in setUp for cleaner gas reports
        callee20.mint(ADDR1, TEST_AMOUNT);
        for (uint256 j = 1; j != 10; j ++) {
            callee721.safeMint(ADDR1, j);
        }

        vm.startPrank(ADDR1);
        callee20.approve(address(bulkTransfer), MAX_INT);
        callee721.setApprovalForAll(address(bulkTransfer), true);
        vm.stopPrank();
    }

    function testGasTransfer20() public {
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](1);
        calls[0] = BulkTransfer.Call(ADDR2, TEST_AMOUNT);
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer20(address(callee20), calls);
    }

    function testGasTransfer20Scale() public {
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](3);
        calls[0] = BulkTransfer.Call(ADDR2, TEST_AMOUNT / 3);
        calls[1] = BulkTransfer.Call(ADDR3, TEST_AMOUNT / 3);
        calls[2] = BulkTransfer.Call(ADDR4, TEST_AMOUNT / 3);
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer20(address(callee20), calls);
    }

    function testGasTransfer721() public {
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](1);
        calls[0] = BulkTransfer.Call(ADDR2, 1);
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(address(callee721), calls);
    }

    function testGasTransfer721Scale() public {
        BulkTransfer.Call[] memory calls = new BulkTransfer.Call[](3);
        calls[0] = BulkTransfer.Call(ADDR2, 1);
        calls[1] = BulkTransfer.Call(ADDR3, 2);
        calls[2] = BulkTransfer.Call(ADDR4, 3);
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721(address(callee721), calls);
    }

    function testGasTransfer721Lite() public {
        uint256[] memory calls = new uint256[](1);
        calls[0] = 1;
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721Lite(address(callee721), ADDR2, calls);
    }

    function testGasTransfer721LiteScale() public {
        uint256[] memory calls = new uint256[](3);
        calls[0] = 1;
        calls[1] = 2;
        calls[2] = 3;
        vm.prank(ADDR1);
        bulkTransfer.bulkTransfer721Lite(address(callee721), ADDR2, calls);
    }

    function testGasBaseline20() public {
        vm.prank(ADDR1);
        callee20.transfer(ADDR2, TEST_AMOUNT);
    }

    function testGasBaseline721() public {
        vm.prank(ADDR1);
        callee721.transferFrom(ADDR1, ADDR2, 1);
    }
}
