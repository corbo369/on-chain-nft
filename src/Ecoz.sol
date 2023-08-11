// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC721A.sol";

interface IThrive {
    function updateThrive(address from, address to) external;
    function burn(address from, uint256 amount) external;
}

interface IMetadata {
    function uriJag(uint256 species, uint256 tokenId, uint256 dna) external view returns (string memory);
    function uriBuck(uint256 species, uint256 tokenId, uint256 dna) external view returns (string memory);
    function uriTree(uint256 species, uint256 tokenId, uint256 dna) external view returns (string memory);
}

contract Ecoz is ERC721A {

    IThrive public thrive;
    IMetadata public metadata;

    struct Population {
        uint16 jag;       uint16 buck;       uint16 tree;
        uint16 babyJag;   uint16 babyBuck;   uint16 babyTree;
        uint16 maxJag;    uint16 maxBuck;    uint16 maxTree;
        uint16 costJag;   uint16 costBuck;   uint16 costTree;
    }

    uint256 currentToken;

    Population public population;

    mapping(uint256 => uint256) public dna;
    mapping(address => uint256) public weight;

    constructor(address metadataAddress, address thriveAddress) ERC721A("Ecoz", "ECOZ") {
        population = Population(0, 0, 0, 0, 0, 0, 3000, 6000, 9000, 900, 600, 300);
        metadata = IMetadata(metadataAddress);
        thrive = IThrive(thriveAddress);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _calculateWeight(uint256 thisDna) internal pure returns (uint256) {
        uint256 total = 0;
        uint256 scale = 0;
        if (thisDna % 1000000 >= 400000) scale = 2;
        else scale = 1;
        while(thisDna > 10) {
            total = total + thisDna % 10;
            thisDna = thisDna / 10;
        }
        return total / scale;
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        if(from != address(0)) {
            weight[from] -= _calculateWeight(dna[startTokenId]);
            thrive.updateThrive(from, to);
        }
        if(to != address(0)) weight[to] += _calculateWeight(dna[startTokenId]);
    }

    function _updateBreedCosts(Population memory p) internal {
        uint16 increment = 3;
        uint256 total = totalSupply();
        uint256 ratioJag = (10000 * (uint256)(p.jag + p.babyJag)) / total;
        uint256 ratioBuck = (10000 * (uint256)(p.buck + p.babyBuck)) / total;
        uint256 ratioTree = (10000 * (uint256)(p.tree + p.babyTree)) / total;

        if(ratioJag > 1667) population.costJag += increment;
        else population.costJag -= increment;
        if(ratioBuck > 3333) population.costBuck += increment;
        else population.costBuck -= increment;
        if(ratioTree > 5000) population.costTree += increment;
        else population.costTree -= increment;
    }

    function _burnJaguar(uint256 tokenId) internal {
        uint256 generation = dna[tokenId] - (dna[tokenId] % 100000);
        require(generation == 100000 || generation == 400000,
            "token id is not a jaguar"
        );

        if (generation == 100000) population.jag--;
        else population.babyJag--;

        _burn(tokenId);
    }

    function _burnBushBuck(uint256 tokenId) internal {
        uint256 generation = dna[tokenId] - (dna[tokenId] % 100000);
        require(generation == 200000 || generation == 500000,
            "token id is not a bush buck"
        );

        if (generation == 100000) population.buck--;
        else population.babyBuck--;

        _burn(tokenId);
    }

    function _burnBananaTree(uint256 tokenId) internal {
        uint256 generation = dna[tokenId] - (dna[tokenId] % 100000);
        require(generation == 300000 || generation == 600000,
            "token id is not a banana tree"
        );

        if (generation == 100000) population.tree--;
        else population.babyTree--;

        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public virtual view override returns(string memory) {
        require(_exists(tokenId), "token ID does not exist");

        uint256 species = dna[tokenId] - (dna[tokenId] % 100000);
        if(species == 100000) return metadata.uriJag(1, tokenId, dna[tokenId]);
        else if (species == 200000) return metadata.uriBuck(2, tokenId, dna[tokenId]);
        else if (species == 300000) return metadata.uriTree(3, tokenId, dna[tokenId]);
        else if (species == 400000) return metadata.uriJag(4, tokenId, dna[tokenId]);
        else if (species == 500000) return metadata.uriBuck(5, tokenId, dna[tokenId]);
        else return metadata.uriTree(6, tokenId, dna[tokenId]);
    }

    function weightEcoz(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "token ID does not exist");
        return _calculateWeight(dna[tokenId]);
    }

    function weightOwner(address user) external view returns (uint256) {
        return weight[user];
    }

    function mintJaguar() public {
        require(population.jag + 1 <= population.maxJag, "exceeds max jag supply");
        thrive.burn(msg.sender, population.costJag);
        currentToken += 1;
        population.jag += 1;

        dna[currentToken] = (uint256(keccak256(abi.encodePacked(
                block.prevrandao, block.timestamp, msg.sender, currentToken))) % 100000) + 100000;

        _mint(msg.sender, 1);
        _updateBreedCosts(population);
    }

    function mintBushBuck() public {
        require(population.buck + 1 <= population.maxBuck, "exceeds max buck supply");
        thrive.burn(msg.sender, population.costBuck);
        currentToken += 1;
        population.buck += 1;

        dna[currentToken] = ((uint256(keccak256(abi.encodePacked(
                block.prevrandao, block.timestamp, msg.sender, currentToken))) % 100000) + 200000);

        _mint(msg.sender, 1);
        _updateBreedCosts(population);
    }

    function mintBananaTree() public {
        require(population.buck + 1 <= population.maxBuck, "exceeds max tree supply");
        thrive.burn(msg.sender, population.costTree);
        currentToken += 1;
        population.tree += 1;

        dna[currentToken] = (uint256(keccak256(abi.encodePacked(
                block.prevrandao, block.timestamp, msg.sender, currentToken))) % 100000) + 300000;

        _mint(msg.sender, 1);
        _updateBreedCosts(population);
    }

    function breedJaguar(uint16 parentOne, uint16 parentTwo) public {
        uint256 dnaOne = dna[parentOne];
        uint256 dnaTwo = dna[parentTwo];
        require(population.babyJag + 1 <= population.maxJag * 2,
            "exceeds max jag supply"
        );
        require(msg.sender == ownerOf(parentOne) && msg.sender == ownerOf(parentOne),
            "you must own both parents"
        );
        require(dnaOne - (dnaOne % 100000) == 100000 && dnaTwo - (dnaTwo % 100000) == 100000,
            "parents must be genesis jaguars"
        );

        thrive.burn(msg.sender, population.costJag / 2);
        currentToken++;
        dna[currentToken] = (uint256(keccak256(abi.encodePacked(
                block.prevrandao, block.timestamp, dnaOne, dnaTwo, currentToken))) % 100000) + 400000;

        population.babyJag++;
        _mint(msg.sender, 1);
        _updateBreedCosts(population);
    }

    function breedBushBuck(uint16 parentOne, uint16 parentTwo) public {
        uint256 dnaOne = dna[parentOne];
        uint256 dnaTwo = dna[parentTwo];
        require(population.buck + 1 <= population.maxBuck * 2,
            "exceeds max buck supply"
        );
        require(msg.sender == ownerOf(parentOne) && msg.sender == ownerOf(parentOne),
            "you must own both parents"
        );
        require(dnaOne - (dnaOne % 100000) == 200000 && dnaTwo - (dnaTwo % 100000) == 200000,
            "parents must be genesis bush bucks"
        );

        thrive.burn(msg.sender, population.costBuck / 2);
        currentToken++;
        dna[currentToken] = (uint256(keccak256(abi.encodePacked(
                block.prevrandao, block.timestamp, dnaOne, dnaTwo, currentToken))) % 100000) + 500000;

        population.babyBuck++;
        _mint(msg.sender, 1);
        _updateBreedCosts(population);
    }

    function breedBananaTree(uint16 parentOne, uint16 parentTwo) public {
        uint256 dnaOne = dna[parentOne];
        uint256 dnaTwo = dna[parentTwo];
        require(population.tree + 1 <= population.maxTree * 2,
            "exceeds max tree supply"
        );
        require(msg.sender == ownerOf(parentOne) && msg.sender == ownerOf(parentOne),
            "you must own both parents"
        );
        require(dnaOne - (dnaOne % 100000) == 300000 && dnaTwo - (dnaTwo % 100000) == 300000,
            "parents must be genesis banana trees"
        );

        thrive.burn(msg.sender, population.costTree / 2);
        currentToken++;
        dna[currentToken] = (uint256(keccak256(abi.encodePacked(
                block.prevrandao, block.timestamp, dnaOne, dnaTwo, currentToken))) % 100000) + 600000;

        population.babyTree++;
        _mint(msg.sender, 1);
        _updateBreedCosts(population);
    }
}