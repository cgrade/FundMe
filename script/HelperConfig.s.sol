// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.t.sol";

/**
 * @title HelperConfig
 * @notice This contract provides configuration for the deployment based on the network.
 */
contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig; // Active network configuration
    uint8 public constant DECIMALS = 8; // Decimals for the price feed
    int256 public constant INITIAL_ANSWER = 200000000000; // Initial answer for the mock price feed

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address.
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    /**
     * @notice Returns the configuration for the Sepolia network.
     * @return The network configuration for Sepolia.
     */
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    /**
     * @notice Creates or returns the configuration for the Anvil network.
     * @return The network configuration for Anvil.
     */
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});
        return anvilConfig;
    }
}
