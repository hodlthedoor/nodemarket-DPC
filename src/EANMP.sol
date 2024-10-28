// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";

contract EarlyAccessNodemarketPass is ERC721, Ownable {
    using Strings for uint256;

    uint256 public currentTokenId;
    uint256 public totalSupply;

    string public baseName;
    string public description;
    string public imageURI;

    error NotAuthorised();
    error TokenDoesNotExist();

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseName,
        string memory _description,
        string memory _imageURI
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        baseName = _baseName;
        description = _description;
        imageURI = _imageURI;
    }

    function mint(address[] calldata recipients) external onlyOwner {
        uint256 numRecipients = recipients.length;
        uint256 tokenId = currentTokenId;

        unchecked {
            for (uint256 i; i < numRecipients; i++) {
                _mint(recipients[i], tokenId + i);
            }

            currentTokenId += numRecipients;
            totalSupply += numRecipients;
        }
    }

    // Burn function, the owner can burn their own NFT, contract owner can burn any NFT
    function burn(uint256 tokenId) external {
        require(msg.sender == ownerOf(tokenId) || msg.sender == owner(), NotAuthorised());
        _burn(tokenId);

        unchecked {
            totalSupply--;
        }
    }

    // Update image URI by the contract owner
    function updateImageURI(string memory newImageURI) external onlyOwner {
        imageURI = newImageURI;
    }

    // tokenURI function returns metadata in a data URL format
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), TokenDoesNotExist());

        return string(
            abi.encodePacked(
                'data:application/json;utf8,{"name": "',
                baseName,
                " #",
                tokenId.toString(),
                '",',
                '"description": "',
                description,
                '",',
                '"image": "',
                imageURI,
                '"}'
            )
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return ownerOf(tokenId) != address(0);
    }
}
