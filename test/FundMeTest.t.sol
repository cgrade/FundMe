// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 2e18;
    uint256 constant FUND_BAL = 100e18;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        fundMe = new DeployFundMe().run();
    }

    function testMinimumDolarIsFive() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log("hello");
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOnwer(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // make the user address
        vm.deal(USER, FUND_BAL); // give the user 100 eth
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.getFunder(0), USER);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        vm.deal(USER, FUND_BAL);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getFunder(0), USER);
    }

    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, FUND_BAL);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arange
        uint256 startingOwnerBalance = fundMe.getOnwer().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOnwer());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOnwer().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

    function testWithdrawWithAMultipleFunder() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFundedIndex = 1;
        for(uint160 i = startingFundedIndex; i < numberOfFunders; i++){
            // hoax is a forge-std that generate and fund and address
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOnwer().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance;
        uint256 endingFundmeBalance;

        // Action
        vm.startPrank(fundMe.getOnwer());
        fundMe.withdraw();
        endingFundmeBalance = address(fundMe).balance;
        endingOwnerBalance = fundMe.getOnwer().balance;
        vm.stopPrank();

        // Assert
        assertEq(endingFundmeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
}
