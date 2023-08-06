// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IEcoz {
    function userWeight(address user) external view returns (uint256);
}

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

//TEST YIELD IS CORRECT
contract Thrive is ERC20, Ownable {

    IEcoz public ecoz;

    bool thrivePaused = true;

    uint256 public genesisBlock;

    uint256 immutable multiplier = 10**18;

    mapping(address => uint256) public thrive;
    mapping(address => uint256) public lastUpdate;

    constructor(uint256 amt) ERC20("Thrive","THRIVE") { _mint(msg.sender, amt); }

    function getPendingThrive(address user) internal view returns(uint256) {
        return ecoz.userWeight(user) * (block.timestamp - (lastUpdate[user] >= genesisBlock ? lastUpdate[user] : genesisBlock)) / 86400;
    }

    function claimThrive() public {
        require(!thrivePaused, "Claiming paused");
        _mint(msg.sender, (thrive[msg.sender] + getPendingThrive(msg.sender)) * multiplier);
        thrive[msg.sender] = 0;
        lastUpdate[msg.sender] = block.timestamp;
    }

    function startThrive() public onlyOwner {
        thrivePaused = !thrivePaused;
        genesisBlock = block.timestamp;
    }

    function setEcoz(address ecozAddress) public onlyOwner {
        ecoz = IEcoz(ecozAddress);
    }

    function updateThrive(address from, address to) external {
        require(msg.sender == address(ecoz));
        if(from != address(0)) {
            thrive[from] += getPendingThrive(from);
            lastUpdate[from] = block.timestamp;
        }
        if(to != address(0)) {
            thrive[to] += getPendingThrive(to);
            lastUpdate[to] = block.timestamp;
        }
    }

    function burn(address user, uint256 amount) external {
        require(msg.sender == address(ecoz));
        uint256 poolAmount = amount / 10;
        _transfer(user, owner(), poolAmount);
        _burn(user, amount - poolAmount);
    }
}