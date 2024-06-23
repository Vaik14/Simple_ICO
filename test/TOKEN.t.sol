// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {TOKEN} from "../src/TOKEN.sol";
import {DeployTOKEN} from "../script/DeployTOKEN.s.sol";

contract TOKENTest is Test {
    TOKEN ecashx;

    address public constant USER_ONE = address(1);
    address public constant USER_TWO = address(2);
    address public constant USER_THREE = address(3);

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant VALUE_TO_MINT = 1e18;

    error TOKEN_NotOwner();

    function setUp() public {
        DeployTOKEN deployer = new DeployTOKEN();
        ecashx = deployer.run();
        vm.deal(USER_ONE, STARTING_USER_BALANCE);
        vm.deal(USER_TWO, STARTING_USER_BALANCE);
        console.log("Owner at deployment", ecashx.owner());
    }

    // _mint
    function testOnlyOwnerCanMintFail() public {
        vm.expectRevert();
        vm.startPrank(USER_ONE);
        ecashx._mint(USER_TWO, STARTING_USER_BALANCE);
    }

    function testOnlyOwnerCanMintPass() public {
        vm.startPrank(ecashx.owner());
        ecashx._mint(USER_TWO, STARTING_USER_BALANCE);
        console.log("USER_TWO token balance", ecashx.balanceOf(USER_TWO));
        assertEq(ecashx.balanceOf(USER_TWO), STARTING_USER_BALANCE);
    }

    function testCanNotmintToZroAddress() public {
        vm.startPrank(ecashx.owner());
        vm.expectRevert();
        ecashx._mint(address(0), STARTING_USER_BALANCE);
    }

    //transfer
    function testTransfer() public {
        vm.startPrank(ecashx.owner());
        console.log("Before transfer balances");
        ecashx._mint(USER_ONE, VALUE_TO_MINT);
        console.log("Balacne User One", ecashx.balanceOf(USER_ONE));
        console.log("balance User Two", ecashx.balanceOf(USER_TWO));
        uint256 value = ecashx.balanceOf(USER_ONE);
        vm.stopPrank();
        vm.startPrank(USER_ONE);
        ecashx.transfer(USER_TWO, value);
        console.log("After transfer balances");
        console.log("Balacne User One", ecashx.balanceOf(USER_ONE));
        console.log("balance User Two", ecashx.balanceOf(USER_TWO));

        assertEq(value, ecashx.balanceOf(USER_TWO));
    }

    function testCanNotTranferToZeroAddress() public {
        vm.startPrank(ecashx.owner());
        ecashx._mint(USER_ONE, VALUE_TO_MINT);
        console.log("Before transfer balances");
        uint256 value = ecashx.balanceOf(USER_ONE);
        console.log("Balacne User One", value);
        vm.stopPrank();
        vm.startPrank(USER_ONE);
        vm.expectRevert();
        ecashx.transfer(address(0), value);
    }

    function testApprove() public {
        vm.startPrank(ecashx.owner());
        ecashx._mint(USER_ONE, VALUE_TO_MINT);
        console.log("Balance of User One", ecashx.balanceOf(USER_ONE));
        uint256 allowance = 1e18;
        vm.startPrank(USER_ONE);
        ecashx.approve(USER_TWO, allowance);
        assertEq(ecashx.allowance(USER_ONE, USER_TWO), allowance);
    }

    //transferFrom
    function testTransferFrom() public {
        vm.startPrank(ecashx.owner());
        ecashx._mint(USER_ONE, VALUE_TO_MINT);
        console.log("Balance of User one", ecashx.balanceOf(USER_ONE));
        vm.stopPrank();
        uint256 allowance = 1e18;
        vm.startPrank(USER_ONE);
        ecashx.approve(USER_TWO, allowance);
        vm.stopPrank();
        vm.startPrank(USER_TWO);
        console.log("Before transfer balance of USER_THREE", ecashx.balanceOf(USER_THREE));
        ecashx.transferFrom(USER_ONE, USER_THREE, allowance);
        console.log("After transfer balance of USER_THREE", ecashx.balanceOf(USER_THREE));
        assertEq(ecashx.balanceOf(USER_THREE), allowance);
    }

    //burn
    function testBurn() public {
        vm.startPrank(ecashx.owner());
        ecashx._mint(USER_ONE, VALUE_TO_MINT);
        vm.stopPrank();
        console.log("Before Burn");
        uint256 userOneBalanceBeforeBurn = ecashx.balanceOf(USER_ONE);
        uint256 totalSupplyBeforeBurn = ecashx.s_totalSupply();
        console.log("userOneBalanceBeforeBurn", userOneBalanceBeforeBurn);
        console.log("totalSupplyBeforeBurn", totalSupplyBeforeBurn);
        vm.startPrank(USER_ONE);
        ecashx.burn(userOneBalanceBeforeBurn);

        console.log("After Burn");
        uint256 userOneBalanceAfterBurn = ecashx.balanceOf(USER_ONE);
        uint256 totalSupplyAfterBurn = ecashx.s_totalSupply();
        console.log("userOneBalanceAfterBurn", userOneBalanceAfterBurn);
        console.log("totalSupplyAfterBurn", totalSupplyAfterBurn);
        assertEq(totalSupplyAfterBurn, 0);
        assertEq(userOneBalanceAfterBurn, 0);
    }

    function testBurnZeroFunds() public {
        vm.startPrank(ecashx.owner());
        ecashx._mint(USER_ONE, VALUE_TO_MINT);
        vm.startPrank(USER_ONE);
        vm.expectRevert(bytes("You can't burn zero funds"));
        ecashx.burn(0);
    }

    function testBurnMoreThanBalance() public {
        vm.startPrank(ecashx.owner());
        ecashx._mint(USER_ONE, VALUE_TO_MINT);
        vm.startPrank(USER_ONE);
        uint256 valueBurn = VALUE_TO_MINT + 1e19;
        vm.expectRevert(bytes("You don't have enough balance!!"));
        ecashx.burn(valueBurn);
    }

    function testBurnFivePercentEveryThreeMonthsFail() public {
        vm.expectRevert("This function can only be called once every 90 days");
        ecashx.burnFivePercentEveryThreeMonths();
    }

    function testBurnFivePercentEveryThreeMonthsPass() public {
        vm.startPrank(ecashx.owner());
        ecashx.mintForBurn(makeAddr("burn"));
        vm.startPrank(ecashx.s_AddressForBurn());
        vm.warp(91 days);
        ecashx.burnFivePercentEveryThreeMonths();
    }

    //can only call once every 3 months
    function testBurnFivePercentEveryThreeMonthsCantCallBeforeThreeMonthsFail() public {
        vm.startPrank(ecashx.owner());
        ecashx.mintForBurn(makeAddr("burn"));
        vm.startPrank(ecashx.s_AddressForBurn());
        vm.expectRevert("This function can only be called once every 90 days");
        ecashx.burnFivePercentEveryThreeMonths();
    }

    function testBurnFivePercentEveryThreeMonthsCantCallBeforeThreeMonthsPass() public {
        vm.startPrank(ecashx.owner());
        ecashx.mintForBurn(makeAddr("burn"));
        vm.startPrank(ecashx.s_AddressForBurn());
        vm.warp(91 days);
        ecashx.burnFivePercentEveryThreeMonths();
        vm.warp(182 days);
        ecashx.burnFivePercentEveryThreeMonths();
    }

    function testmintForBurnOnlyOwerCanCallFail() public {
        vm.expectRevert();
        ecashx.mintForBurn(makeAddr("Burn"));
    }

    function testmintForBurnOnlyOwerCanCallPass() public {
        vm.startPrank(ecashx.owner());
        ecashx.mintForBurn(makeAddr("Burn"));
    }

    function testmintForBurnCantToZeroAddress() public {
        vm.startPrank(ecashx.owner());
        vm.expectRevert();
        ecashx.mintForBurn(address(0));
    }

    function testmintForSaleOnlyOwerCanCallFail() public {
        vm.startPrank(ecashx.owner());
        ecashx.mintForSale(makeAddr("Sale"));
    }

    function testmintForSaleOnlyOwerCanCallPass() public {
        vm.startPrank(ecashx.owner());
        ecashx.mintForSale(makeAddr("Sale"));
    }

    function testmintForSaleCantToZeroAddressFail() public {
        ecashx.owner();
        vm.expectRevert();
        ecashx.mintForSale(address(0));
    }

    function testmintForReserveOnlyOwerCanCallFail() public {
        vm.expectRevert();
        ecashx.mintForReserve(makeAddr("Reserve"));
    }

    function testmintForReserveOnlyOwerCanCallPass() public {
        vm.startPrank(ecashx.owner());
        ecashx.mintForReserve(makeAddr("Reserve"));
    }

    function testmintForReserveCantToZeroAddress() public {
        vm.startPrank(ecashx.owner());
        vm.expectRevert();
        ecashx.mintForReserve(address(0));
    }
}
