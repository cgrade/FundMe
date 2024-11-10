// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

/**
 * @title FundMe
 * @notice This contract allows users to fund and withdraw ETH.
 */
contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded; // Mapping of funders to their funded amounts
    address[] private s_funders; // Array of funders

    address private immutable i_owner; // Owner of the contract
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18; // Minimum funding amount in USD
    AggregatorV3Interface private s_priceFeed; // Price feed interface

    /**
     * @notice Constructor to set the price feed address and owner.
     * @param priceFeed The address of the price feed contract.
     */
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /**
     * @notice Allows users to fund the contract.
     */
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    /**
     * @notice Returns the version of the price feed.
     * @return The version of the price feed.
     */
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    /**
     * @notice Allows the owner to withdraw funds from the contract.
     */
    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    /**
     * @notice Fallback function to handle incoming ETH.
     */
    fallback() external payable {
        fund();
    }

    /**
     * @notice Receive function to handle incoming ETH.
     */
    receive() external payable {
        fund();
    }

    /**
     * @notice Returns the amount funded by a specific address.
     * @param addressToCheck The address to check.
     * @return The amount funded by the address.
     */
    function getAddressToAmountFunded(address addressToCheck) public view returns (uint256) {
        return s_addressToAmountFunded[addressToCheck];
    }

    /**
     * @notice Returns the funder at a specific index.
     * @param index The index of the funder.
     * @return The address of the funder.
     */
    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    /**
     * @notice Returns the owner of the contract.
     * @return The address of the owner.
     */
    function getOnwer() public view returns (address) {
        return i_owner;
    }
}
