// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {console2} from "forge-std/Script.sol";
import {TOKEN} from "../src/TOKEN.sol";
import {DeployTOKEN} from "../script/DeployTOKEN.s.sol";
import {TestUSDT} from "../src/TestUSDT.sol";
import {DeployTestUSDT} from "../script/DeployTestUSDT.s.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {DeployTokenSale} from "../script/DeployTokenSale.sol";

contract TokenSaleTest is Test {
    TOKEN public ecashToken;
    TestUSDT public tusdt;
    TokenSale public tokensale;

    address public constant USER_ONE = address(1);
    address public constant USER_TWO = address(2);
    address public constant USER_THREE = address(3);

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant VALUE_TO_MINT = 1e18;

    function setUp() public {
        DeployTOKEN deployerEcash = new DeployTOKEN();
        ecashToken = deployerEcash.run();
        DeployTestUSDT deployerTUSDT = new DeployTestUSDT();
        tusdt = deployerTUSDT.run();
        DeployTokenSale deployerTokenSale = new DeployTokenSale();
        tokensale = deployerTokenSale.run();
    }

    // _mint
    function testOnlyOwnerCanMintFail() public {
        vm.expectRevert();
        vm.startPrank(USER_ONE);
        ecashToken._mint(USER_TWO, STARTING_USER_BALANCE);
    }
}
