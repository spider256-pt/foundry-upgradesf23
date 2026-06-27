//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {
    UUPSUpgradeable
} from "@openzeppelin-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

import {
    Initializable
} from "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";

import {
    OwnableUpgradeable
} from "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract BoxV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 internal number;

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {}

    function setNumber(uint256 _number) external returns (uint256) {
        number = _number;
    }

    function getNumber() external returns (uint256) {
        return number;
    }

    function version() external returns (uint256) {
        return 2;
    }

    function _authorizeUpgrade(address newImplementation) internal override {}
}
