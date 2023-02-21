// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Utilities} from "./utils/Utilities.sol";
import "forge-std/Test.sol";

import {Evolution} from "../src/Evolution.sol";
import {Metadata} from "../src/Metadata.sol";

contract EvolutionTest is Test {

    Utilities internal utils;
    Evolution internal evolution;
    Metadata internal metadata;

    address payable internal owner;
    address payable internal user;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);
        owner = users[0];
        user = users[1];

        vm.label(owner, "Owner");
        vm.label(user, "User");

        metadata = new Metadata();
        evolution = new Evolution(address(metadata));
    }

    function testMint() public {
        evolution.mint(5);
        evolution.tokenURI(0);
    }
}
