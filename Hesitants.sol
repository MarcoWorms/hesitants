// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Hesitants is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256 public mintPrice = 0.0001 ether;

    constructor() Ownable(msg.sender) ERC721("Hesitants", "HES") {}

    function withdrawMintEther() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        super.transferOwnership(newOwner);
    }

    function mint() public payable {
        require(msg.value >= mintPrice, "Insufficient payment");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        mintPrice += 0.0001 ether;
    }

    function getMintPrice() public view returns (uint256) {
        return mintPrice;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        string memory svg = generateSVG(tokenId);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Hesitant #',
                        tokenId.toString(),
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function generateSVG(uint256 tokenId) internal pure returns (string memory) {
        uint256 randomSeed = uint256(keccak256(abi.encodePacked(tokenId)));
        string memory svg = '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" style="background-color: white;">';
        for (uint256 i = 0; i < 1; i++) {
            uint256 x1 = random(randomSeed, i) % 270 + 30;
            uint256 y1 = random(randomSeed, i + 1) % 270 + 30;
            uint256 x2 = random(randomSeed, i + 2) % 270 + 30;
            uint256 y2 = random(randomSeed, i + 3) % 270 + 30;
            svg = string(abi.encodePacked(
                svg,
                '<line x1="', x1.toString(), '" y1="', y1.toString(),
                '" x2="', x2.toString(), '" y2="', y2.toString(),
                '" stroke="black" />'
            ));
        }
        for (uint256 i = 0; i < 2; i++) {
            uint256 cx = random(randomSeed, i + 4) % 240 + 30;
            uint256 cy = random(randomSeed, i + 5) % 240 + 30;
            uint256 r = random(randomSeed, i + 6) % 5 + 5;
            svg = string(abi.encodePacked(
                svg,
                '<circle cx="', cx.toString(), '" cy="', cy.toString(),
                '" r="', r.toString(), '" fill="black" />'
            ));
        }
        svg = string(abi.encodePacked(svg, "</svg>"));
        return svg;
    }

    function random(uint256 seed, uint256 offset) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed, offset)));
    }
}
