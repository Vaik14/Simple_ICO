// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {TOKEN} from "../src/TOKEN.sol";

contract DeployTOKEN is Script {
    TOKEN public token;

    function run() public returns (TOKEN) {
        token = new TOKEN();
        return token;
    }
}
