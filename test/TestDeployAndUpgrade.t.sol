//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract TestDeployAndUpgrade is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public owner = makeAddr("owner");

    // address public proxy;
    address proxyAddress;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();

        proxyAddress = deployer.run();
    }

    function testVersionBoxV1() public {
        uint256 expectedVersion = 1;
        assertEq(expectedVersion, BoxV1(proxyAddress).version());
    }

    function testsetNummberandGetnumberV1() public {
        console.log("The Version 1 does not have a function to setNumber");
        bytes memory data = abi.encodeWithSignature("setNumber(uint256)", 67);
        (bool success, ) = proxyAddress.call(data);
        assertFalse(success, "There is no such function like setNumber");

        assertEq(BoxV1(proxyAddress).getNumber(), 0);
    }

    function testUpgradefromV1toV2() public {
        BoxV2 boxV2 = new BoxV2();
        upgrader.upgradeBox(proxyAddress, address(boxV2));

        uint256 expected_Version = 2;

        assertEq(expected_Version, BoxV2(proxyAddress).version());
    }

    function testsetNumberAsV1() public {
        vm.expectRevert();
        BoxV2(proxyAddress).setNumber(7);
    }
}
