// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Base64.sol";
import "./AnonymiceLibrary.sol";
import "openzeppelin-contracts/access/Ownable.sol";

//BETTER NAMES. GET OTHERS TRAITS IN
contract Metadata is Ownable {

    struct Trait {
        string name;
        string value;
        string pixels;
        uint16 count;
    }

    string[87] keys;
    string[87] hexJag;
    string[87] hexBuck;
    string[87] hexTree;

    address public ecoz;

    mapping (uint256 => mapping(uint256 => Trait[])) traitTypes;

    mapping (uint256 => mapping(uint256 => uint256)) traitTypeCounts;

    function _keyToNumber(string memory letter)
        internal
        view
        returns (uint8)
    {
        for (uint8 i = 0; i < 87; i++) {
            if (
                keccak256(abi.encodePacked((keys[i]))) ==
                keccak256(abi.encodePacked((letter)))
            ) return i;
        } revert();
    }

    //Make 3 seperate ones
    function _keyToColor(uint256 species, string memory key)
        internal
        view
        returns (string memory)
    {
        if (species == 1) {
            for (uint8 i = 0; i < 87; i++) {
                if (
                    keccak256(abi.encodePacked((keys[i]))) ==
                    keccak256(abi.encodePacked((key)))
                ) return hexJag[i];
            } revert();
        }
        else if (species == 2) {
            for (uint8 i = 0; i < 87; i++) {
                if (
                    keccak256(abi.encodePacked((keys[i]))) ==
                    keccak256(abi.encodePacked((key)))
                ) return hexBuck[i];
            } revert();
        }
        else {
            for (uint8 i = 0; i < 87; i++) {
                if (
                    keccak256(abi.encodePacked((keys[i]))) ==
                    keccak256(abi.encodePacked((key)))
                ) return hexTree[i];
            }
        } revert();
    }


    function addTrait(uint256 species, uint256 count, uint256 index, Trait[9] memory trait)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < 9; i++) {
            traitTypes[species][index].push(
                Trait(
                    trait[i].name, trait[i].value,
                    trait[i].pixels, trait[i].count
                )
            );
        }
        traitTypeCounts[species][index] = count;
    }

    function setHexKey(string[87] memory _keys, string[87] memory _jag, string[87] memory _buck, string[87] memory _tree)
        public
        onlyOwner
    {
        keys = _keys; hexJag = _jag; hexBuck = _buck; hexTree = _tree;
    }

    function setEcoz(address _ecoz)
        public
        onlyOwner
    {
        ecoz = _ecoz;
    }

    function uriJag(uint256 species, uint256 tokenId, uint256 dna) external view returns (string memory) {
        string memory svg;
        string memory metadata;
        string memory background = 'f0f0f0';
        bool[32][32] memory placedPixels;

        for (uint256 i = 5; i > 0; i--) {
            uint256 thisTrait = AnonymiceLibrary.parseInt(
                AnonymiceLibrary.substring(AnonymiceLibrary.toString(dna), i, i + 1));
            if(thisTrait == traitTypeCounts[species][i]) thisTrait = 0;
            if(thisTrait > traitTypeCounts[species][i]) thisTrait = thisTrait % (traitTypeCounts[species][i] - 1);

            for (uint16 j = 0; j < traitTypes[species][i][thisTrait].count; j++) {
                string memory pixel = AnonymiceLibrary.substring(traitTypes[species][i][thisTrait].pixels, j * 3, j * 3 + 3);
                uint8 x = _keyToNumber(AnonymiceLibrary.substring(pixel, 0, 1));
                uint8 y = _keyToNumber(AnonymiceLibrary.substring(pixel, 1, 2));

                if (placedPixels[x][y]) continue;
                svg = string(
                    abi.encodePacked(
                        svg,"<rect fill='#",
                        _keyToColor(species, AnonymiceLibrary.substring(pixel, 2, 3)),
                        "' x='",AnonymiceLibrary.toString(x),
                        "' y='",AnonymiceLibrary.toString(y),"'/>"
                    )
                );
                placedPixels[x][y] = true;
            }

            //GENESIS JAGS
            if(i == 1) {
                for (uint16 j = 0; j < traitTypes[species][6][thisTrait].count; j++) {
                    string memory pixel = AnonymiceLibrary.substring(traitTypes[species][6][thisTrait].pixels, j * 3, j * 3 + 3);
                    uint8 x = _keyToNumber(AnonymiceLibrary.substring(pixel, 0, 1));
                    uint8 y = _keyToNumber(AnonymiceLibrary.substring(pixel, 1, 2));

                    if (placedPixels[x][y]) continue;
                    svg = string(
                        abi.encodePacked(
                            svg,"<rect fill='#",
                            _keyToColor(species, AnonymiceLibrary.substring(pixel, 2, 3)),
                            "' x='",AnonymiceLibrary.toString(x),
                            "' y='",AnonymiceLibrary.toString(y),"'/>"
                        )
                    );
                    placedPixels[x][y] = true;
                }
            }
            //GENESIS JAGS

            metadata = string(
                abi.encodePacked(metadata,
                '{"trait_type":"', traitTypes[species][i][thisTrait].value,
                '","value":"', traitTypes[species][i][thisTrait].name,'"}')
            );
            if (i != 1) metadata = string(abi.encodePacked(metadata, ","));
            else metadata = string(abi.encodePacked(metadata, "]}"));
        }

        svg = string(
            AnonymiceLibrary.encode(bytes(abi.encodePacked(
                '<svg id="ecoz-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 32 32"> <rect class="bg" x="0" y="0" />',
                svg,
                '<style>rect.bg{width:32px;height:32px;fill:#', background,'} rect{width:1px;height:1px;} #ecoz-svg{shape-rendering: crispedges;} </style></svg>'
            )))
        );

        if (species == 1) return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":"Jaguar #"',AnonymiceLibrary.toString(tokenId),
                    '", "description":"',
                    "The Jaguar Ecoz is the Apex Predator of the Ecozystem. No one dare challenge the Jaguar. The only thing that can stop him from thriving in the jungle is starvation...",
                    '", "image": "',
                    'data:image/svg+xml;base64,', svg,
                    '", "attributes": [',
                    '{"trait_type":"Species","value":"Jaguar"},',
                    '{"trait_type":"Generation","value":"Genesis"},',
                    '{"trait_type":"DNA","value":"',AnonymiceLibrary.toString(dna),'"},',
                    metadata)))));
        else return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":"Jaguar #"',AnonymiceLibrary.toString(tokenId),
                    '", "description":"',
                    "The Jaguar Ecoz is the Apex Predator of the Ecozystem. No one dare challenge the Jaguar. The only thing that can stop him from thriving in the jungle is starvation...",
                    '", "image": "',
                    'data:image/svg+xml;base64,', svg,
                    '", "attributes": [',
                    '{"trait_type":"Species","value":"Jaguar"},',
                    '{"trait_type":"Generation","value":"Baby"},',
                    '{"trait_type":"DNA","value":"',AnonymiceLibrary.toString(dna),'"},',
                    metadata)))));
    }


    function uriBuck(uint256 species, uint256 tokenId, uint256 dna) external view returns (string memory) {
        string memory svg;
        string memory metadata;
        string memory background = 'f0f0f0';
        bool[32][32] memory placedPixels;

        for (uint256 i = 5; i > 0; i--) {
            uint256 thisTrait = AnonymiceLibrary.parseInt(
                AnonymiceLibrary.substring(AnonymiceLibrary.toString(dna), i, i + 1));
            if(thisTrait == traitTypeCounts[species][i]) thisTrait = 0;
            if(thisTrait > traitTypeCounts[species][i]) thisTrait = thisTrait % (traitTypeCounts[species][i] - 1);

            for (uint16 j = 0; j < traitTypes[species][i][thisTrait].count; j++) {
                string memory pixel = AnonymiceLibrary.substring(traitTypes[species][i][thisTrait].pixels, j * 3, j * 3 + 3);
                uint8 x = _keyToNumber(AnonymiceLibrary.substring(pixel, 0, 1));
                uint8 y = _keyToNumber(AnonymiceLibrary.substring(pixel, 1, 2));

                if (placedPixels[x][y]) continue;
                svg = string(
                    abi.encodePacked(
                        svg,"<rect fill='#",
                        _keyToColor(species, AnonymiceLibrary.substring(pixel, 2, 3)),
                        "' x='",AnonymiceLibrary.toString(x),
                        "' y='",AnonymiceLibrary.toString(y),"'/>"
                    )
                );
                placedPixels[x][y] = true;
            }

            metadata = string(
                abi.encodePacked(metadata,
                '{"trait_type":"', traitTypes[species][i][thisTrait].value,
                '","value":"', traitTypes[species][i][thisTrait].name,'"}')
            );
            if (i != 1) metadata = string(abi.encodePacked(metadata, ","));
            else metadata = string(abi.encodePacked(metadata, "]}"));
        }

        svg = string(
            AnonymiceLibrary.encode(bytes(abi.encodePacked(
                '<svg id="ecoz-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 32 32"> <rect class="bg" x="0" y="0" />',
                svg,
                '<style>rect.bg{width:32px;height:32px;fill:#', background,'} rect{width:1px;height:1px;} #ecoz-svg{shape-rendering: crispedges;} </style></svg>'
            )))
        );

        if (species == 2) return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":"Bush Buck #"',AnonymiceLibrary.toString(tokenId),
                    '", "description":"',
                    "DESC_HERE",
                    '", "image": "',
                    'data:image/svg+xml;base64,', svg,
                    '", "attributes": [',
                    '{"trait_type":"Species","value":"Jaguar"},',
                    '{"trait_type":"Generation","value":"Genesis"},',
                    '{"trait_type":"DNA","value":"',AnonymiceLibrary.toString(dna),'"},',
                    metadata)))));

        else return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":"Bush Buck #"',AnonymiceLibrary.toString(tokenId),
                    '", "description":"',
                    "DESC_HERE",
                    '", "image": "',
                    'data:image/svg+xml;base64,', svg,
                    '", "attributes": [',
                    '{"trait_type":"Species","value":"Bush Buck"},',
                    '{"trait_type":"Generation","value":"Baby"},',
                    '{"trait_type":"DNA","value":"',AnonymiceLibrary.toString(dna),'"},',
                    metadata)))));
    }

    function uriTree(uint256 species, uint256 tokenId, uint256 dna) external view returns (string memory) {
        string memory generation;
        if(species == 3) generation = "Genesis";
        else generation = "Baby";
        return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":',
                    '"Banana Tree #',
                    AnonymiceLibrary.toString(tokenId),
                    '", "description":"',
                    "Creatures Evolving On The Ethereum Blockchain",
                    '", "image": "',
                    'data:image/svg+xml;base64,',
                    //svg(species, dna),'",',
                    '"attributes": [',
                    '{"trait_type":"Species","value":"Banana Tree"},',
                    '{"trait_type":"Generation","value":"',generation,'"},',
                    '{"trait_type":"DNA","value":"', AnonymiceLibrary.toString(dna),'"}',
                    //metadata(species, dna),']',
                    '}')))));
    }
}