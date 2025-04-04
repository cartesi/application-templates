// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std-1.9.6/src/Script.sol";
import "../src/MyContract.sol";

contract Deploy is Script {
    /// @notice Simple deploy script to deploy the solidity contract contained in MyContract.sol
    /// @dev Replace the first deployment argument with the address of the coprocessor task issues for deployment chain
    /// @dev Replace the second deployment argument with the machine has for the cartesi backend code whose execution you intend to run.
    function run() external {
        vm.startBroadcast();
        new MyContract(
            address(0x95401dc811bb5740090279Ba06cfA8fcF6113778),
            hex"0000000000000000000000000000000000000000"
        );
        vm.stopBroadcast();
    }
}
