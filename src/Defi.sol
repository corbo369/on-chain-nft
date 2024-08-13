// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/access/Ownable.sol";

contract MysteryBox is ERC721, Ownable {

    uint256 public totalSupply;
    uint256 public maxSupply = 3000;
    uint256 public cost = 0.03 ether;

    mapping(uint256 => bool) public isOpen;

    constructor() ERC721("Mystery Box","MSTR") {}

    function mint() external payable {
        require(totalSupply + 1 <= maxSupply, "Exceeds max supply");
        require(msg.value == cost, "Incorrect ether value");

        totalSupply++;
        _mint(msg.sender, totalSupply);
    }
}
