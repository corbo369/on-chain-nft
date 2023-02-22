// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Base64.sol";
import "./AnonymiceLibrary.sol";

interface IEvolution {}

contract Metadata {
    IEvolution public evolution;

    function draw(string memory _svg, string memory _color, uint8 _x, uint8 _y, uint8 _width, uint8 _height) internal pure returns(string memory) {
        for(uint8 i = _x; i <= _x + _width; i++) {
            for(uint8 j = _y; j <= _y + _height; j++) {
                if(i < 16 && j < 16) {
                    _svg = string(abi.encodePacked(_svg,"<rect fill='#",_color,"' x='",AnonymiceLibrary.toString(i),"' y='",AnonymiceLibrary.toString(j),"'/>"));
                }
            }
        }
        return _svg;
    }

    function svg(uint256[] memory _dna) internal pure returns(string memory) {
        string memory svgString;
        string memory background = 'f2fffd';
        for(uint256 i = 0; i < _dna.length; i++) {
            string memory dna = AnonymiceLibrary.toString(_dna[i]);
            uint256 spacer = 0;
            //iterate 9 times
            while(spacer <= 66) {
                string memory color = AnonymiceLibrary.substring(dna, spacer, spacer + 6);
                uint8 x = AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(dna, spacer, spacer + 2)) % 16;
                uint8 y = AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(dna, spacer + 2, spacer + 4)) % 16;
                uint8 width = AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(dna, spacer + 4, spacer + 5)) % 16;
                uint8 height = AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(dna, spacer + 5, spacer + 6)) % 16;
                svgString = draw(svgString, color, x, y, width, height);
                spacer += 6;
            }
        }
        svgString = string(
            AnonymiceLibrary.encode(bytes(abi.encodePacked(
                '<svg id="evolution-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 16 16"> <rect class="bg" x="0" y="0" />',
                svgString,
                '<style>rect.bg{width:16px;height:16px;fill:#',background,'} rect{width:1px;height:1px;} #evolution-svg{shape-rendering: crispedges;} </style></svg>'
            )))
        );
        return svgString;
    }

    function metadata(uint256 _dna) internal pure returns(string memory) {
        string memory metadataString = string(abi.encodePacked('{"trait_type":"DNA","value":"',AnonymiceLibrary.toString(_dna),'"}'));
        return metadataString;
    }

    function uri(uint256 tokenID, uint256[] memory tokenDNA) external pure returns(string memory) {
        return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":',
                    '"Creature #',
                    AnonymiceLibrary.toString(tokenID),
                    '", "description":"',
                    "Creatures Evolving On The Ethereum Blockchain",
                    '", "image": "',
                    'data:image/svg+xml;base64,',
                    svg(tokenDNA),'",',
                    '"attributes": [',
                    metadata(tokenDNA[0]),']',
                    '}')))));
    }
}
