// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

/**
 * @title DeployFundMe
 * @notice This contract is responsible for deploying the FundMe contract.
 */
contract DeployFundMe is Script {
    FundMe fundMe;

    /**
     * @notice Runs the deployment script for the FundMe contract.
     * @return fundMe The deployed FundMe contract instance.
     */
    function run() public returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
