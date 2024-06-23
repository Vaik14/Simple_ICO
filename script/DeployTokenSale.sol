// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/Script.sol";
import {TOKEN} from "../src/TOKEN.sol";
import {TestUSDT} from "../src/TestUSDT.sol";
import {TokenSale} from "../src/TokenSale.sol";

contract DeployTokenSale is Script {
    TOKEN public ecashToken;
    TestUSDT public tusdt;
    TokenSale public tokensale;

    function run() public returns (TokenSale) {
        ecashToken = new TOKEN();
        address ecashAddress = address(ecashToken);
        tusdt = new TestUSDT();
        address tusdtAddress = address(tusdt);
        tokensale = new TokenSale(tusdtAddress, ecashAddress);
        return tokensale;
    }
}
