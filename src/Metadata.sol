// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Base64.sol";
import "./AnonymiceLibrary.sol";

interface IEvolution {}

contract Metadata {
    IEvolution public evolution;

    string[] species = [""];

    function svg(uint256 _dna) internal pure returns(string memory) {
        string memory svgString;
        string memory background = 'ffffff';
        string memory dna = Library.toString(_dna);
        for(uint256 i = 0; i < 12; i++) {
            uint256 spacer = 0;
            for(uint256 j = 0; j < 12; j++) {
                svgString = string(abi.encodePacked(svgString,"<rect fill='#",Library.substring(dna, spacer, spacer + 6),"' x='",Library.toString(j),"' y='",Library.toString(i),"'/>"));
                spacer += 6;
            }
        }
        svgString = string(
            Library.encode(bytes(abi.encodePacked(
                '<svg id="evolution-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 12 12"> <rect class="bg" x="0" y="0" />',
                svgString,
                '<style>rect.bg{width:32px;height:32px;fill:#',background,'} rect{width:1px;height:1px;} #evolution-svg{shape-rendering: crispedges;} </style></svg>'
            )))
        );
        return svgString;
    }

    function metadata(uint256 _dna) internal pure returns(string memory) {
        string memory metadataString = string(abi.encodePacked('{"trait_type":"DNA","value":"',Library.toString(_dna),'"}'));
        return metadataString;
    }

    function uri(uint256 tokenID, uint256 tokenDNA) external pure returns(string memory) {
        return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":',
                    '"Creature #',
                    Library.toString(tokenID),
                    '", "description":"',
                    "Creatures Evolving On The Ethereum Blockchain",
                    '", "image": "',
                    'data:image/svg+xml;base64,',
                    svg(tokenDNA),'",',
                    '"attributes": [',
                    metadata(tokenDNA),']',
                    '}')))
            )
        );
    }
}
