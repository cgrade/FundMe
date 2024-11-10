// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

/**
 * @title FundMeTest
 * @notice This contract contains tests for the FundMe contract.
 */
contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 2e18; // Amount to send for funding
    uint256 constant FUND_BAL = 100e18; // Total balance for funding

    function setUp() external {
        fundMe = new DeployFundMe().run(); // Deploy the FundMe contract
    }

    function testMinimumDolarIsFive() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // Test minimum funding amount
        console.log("hello");
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOnwer(), msg.sender); // Test that the owner is the message sender
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4); // Test the price feed version
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert("You need to spend more ETH!"); // Expect revert for insufficient ETH
        fundMe.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // Simulate user funding
        vm.deal(USER, FUND_BAL); // Give the user 100 ETH
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE); // Check funded amount
        assertEq(fundMe.getFunder(0), USER); // Check funder address
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        vm.deal(USER, FUND_BAL);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getFunder(0), USER); // Check if user is added to funders
    }

    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, FUND_BAL);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); // Simulate a non-owner trying to withdraw
        vm.expectRevert(); // Expect revert for non-owner
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOnwer().balance; // Owner's starting balance
        uint256 startingFundMeBalance = address(fundMe).balance; // FundMe's starting balance

        vm.prank(fundMe.getOnwer());
        fundMe.withdraw(); // Owner withdraws funds

        uint256 endingOwnerBalance = fundMe.getOnwer().balance; // Owner's ending balance
        uint256 endingFundMeBalance = address(fundMe).balance; // FundMe's ending balance
        assertEq(endingFundMeBalance, 0); // Check FundMe balance is zero
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // Check total balance
    }

    function testWithdrawWithAMultipleFunder() public funded {
        uint160 numberOfFunders = 10; // Number of funders
        uint160 startingFundedIndex = 1; // Starting index for funders
        for (uint160 i = startingFundedIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // Generate and fund an address
            fundMe.fund{value: SEND_VALUE}(); // Fund the contract
        }

        uint256 startingOwnerBalance = fundMe.getOnwer().balance; // Owner's starting balance
        uint256 startingFundMeBalance = address(fundMe).balance; // FundMe's starting balance
        uint256 endingOwnerBalance;
        uint256 endingFundmeBalance;

        vm.startPrank(fundMe.getOnwer());
        fundMe.withdraw(); // Owner withdraws funds
        endingFundmeBalance = address(fundMe).balance; // FundMe's ending balance
        endingOwnerBalance = fundMe.getOnwer().balance; // Owner's ending balance
        vm.stopPrank();

        assertEq(endingFundmeBalance, 0); // Check FundMe balance is zero
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // Check total balance
    }
}
