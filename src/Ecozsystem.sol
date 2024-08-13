// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "openzeppelin-contracts/access/Ownable.sol";

interface IEcoz {
    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;
}

contract Ecozsystem is Ownable {

    IEcoz public ecoz;

    constructor(address ecozAddress) {
        ecoz = IEcoz(ecozAddress);
    }
}