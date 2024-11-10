// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title MockV3Aggregator
 * @notice This contract mocks the behavior of a price aggregator for testing purposes.
 */
contract MockV3Aggregator is AggregatorV3Interface {
    uint256 public constant version = 4; // Version of the aggregator

    uint8 public decimals; // Decimals for the price
    int256 public latestAnswer; // Latest price answer
    uint256 public latestTimestamp; // Timestamp of the latest answer
    uint256 public latestRound; // Latest round ID

    mapping(uint256 => int256) public getAnswer; // Mapping of round ID to answer
    mapping(uint256 => uint256) public getTimestamp; // Mapping of round ID to timestamp
    mapping(uint256 => uint256) private getStartedAt; // Mapping of round ID to start time

    /**
     * @notice Constructor to initialize the mock aggregator.
     * @param _decimals The number of decimals for the price.
     * @param _initialAnswer The initial price answer.
     */
    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        updateAnswer(_initialAnswer); // Set the initial answer
    }

    /**
     * @notice Updates the latest answer and round data.
     * @param _answer The new price answer.
     */
    function updateAnswer(int256 _answer) public {
        latestAnswer = _answer;
        latestTimestamp = block.timestamp;
        latestRound++;
        getAnswer[latestRound] = _answer;
        getTimestamp[latestRound] = block.timestamp;
        getStartedAt[latestRound] = block.timestamp;
    }

    /**
     * @notice Updates round data for a specific round ID.
     * @param _roundId The round ID to update.
     * @param _answer The new price answer.
     * @param _timestamp The timestamp of the answer.
     * @param _startedAt The start time of the round.
     */
    function updateRoundData(uint80 _roundId, int256 _answer, uint256 _timestamp, uint256 _startedAt) public {
        latestRound = _roundId;
        latestAnswer = _answer;
        latestTimestamp = _timestamp;
        getAnswer[latestRound] = _answer;
        getTimestamp[latestRound] = _timestamp;
        getStartedAt[latestRound] = _startedAt;
    }

    /**
     * @notice Returns the data for a specific round.
     * @param _roundId The round ID to query.
     * @return roundId The round ID.
     * @return answer The price answer for the round.
     * @return startedAt The start time of the round.
     * @return updatedAt The timestamp of the answer.
     * @return answeredInRound The round ID in which the answer was provided.
     */
    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, getAnswer[_roundId], getStartedAt[_roundId], getTimestamp[_roundId], _roundId);
    }

    /**
     * @notice Returns the latest round data.
     * @return roundId The latest round ID.
     * @return answer The latest price answer.
     * @return startedAt The start time of the latest round.
     * @return updatedAt The timestamp of the latest answer.
     * @return answeredInRound The round ID in which the latest answer was provided.
     */
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (
            uint80(latestRound),
            getAnswer[latestRound],
            getStartedAt[latestRound],
            getTimestamp[latestRound],
            uint80(latestRound)
        );
    }

    /**
     * @notice Returns a description of the aggregator.
     * @return A string description of the aggregator.
     */
    function description() external pure returns (string memory) {
        return "v0.6/test/mock/MockV3Aggregator.sol";
    }
}
