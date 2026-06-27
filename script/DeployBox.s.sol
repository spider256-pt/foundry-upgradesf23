//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {
    ERC1967Proxy
} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployBox is Script {
    BoxV1 public boxV1;
    ERC1967Proxy public ercproxy;

    function run() external returns (address) {
        address proxy = deployBox();
        return proxy;
    }

    function deployBox() public returns (address) {
        vm.startBroadcast();

        boxV1 = new BoxV1();
        ercproxy = new ERC1967Proxy(address(boxV1), "");
        BoxV1(address(ercproxy)).initialize();
        vm.stopBroadcast();
        return address(ercproxy);
    }
}
