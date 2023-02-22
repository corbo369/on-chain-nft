// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC721A.sol";
//import "openzeppelin/contracts/access/Ownable.sol";

interface IMetadata {
    function uri(uint256 tokenID, uint256[] memory tokenDNA) external view returns(string memory);
}

contract Evolution is ERC721A {

    IMetadata public metadataAddress;

    uint256 public cutoff = 0;
    uint256 public cost = 0 ether;

    mapping(uint256 => uint256[]) public tokenToDNA;

    constructor(address _metadata) ERC721A("Evolution", "EVOL") {
        metadataAddress = IMetadata(_metadata);
        cutoff = block.timestamp + 1 days;
    }

    function generateDNA(address _user, uint256 _tokenID) internal {
        tokenToDNA[_tokenID].push(uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, _user, _tokenID))));
    }

    function mint(uint256 amount) public payable {
        require(block.timestamp <= cutoff, "mint window is closed");
        require(msg.value == amount * cost, "incorrect ether value");

        for(uint256 i = totalSupply(); i < amount; ++i) {
            generateDNA(msg.sender, i);
        }

        _mint(msg.sender, amount);
    }

    function combine(uint256 one, uint256 two) public {
        require(msg.sender == ownerOf(one) && msg.sender == ownerOf(two), "Not your tokens");

        _burn(two);
        for(uint256 i = 0; i < tokenToDNA[two].length; i++) {
            tokenToDNA[one].push(tokenToDNA[two][i]);
        }
        delete(tokenToDNA[two]);
    }

    function tokenURI(uint256 tokenID) public virtual view override returns(string memory) {
        require(_exists(tokenID), "Token ID does not exist!");
        return metadataAddress.uri(tokenID, tokenToDNA[tokenID]);
    }
}
