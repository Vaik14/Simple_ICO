// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {TestUSDT} from "../src/TestUSDT.sol";

contract DeployTestUSDT is Script {
    TestUSDT public token;

    function run() public returns (TestUSDT) {
        token = new TestUSDT();
        return token;
    }
}
