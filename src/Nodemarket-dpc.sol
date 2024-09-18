// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@solmate/tokens/ERC721.sol";
import "@openzeppelin/access/Ownable.sol";

contract NodemarketDPC is ERC721, Ownable {
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
    ) ERC721(_name, _symbol) Ownable(msg.sender){
        baseName = _baseName;
        description = _description;
        imageURI = _imageURI;
    }

    // Mint function to mint NFTs to an address
    function mint(address to) external onlyOwner {
        uint256 tokenId = currentTokenId;
        _mint(to, tokenId);

        unchecked{
            currentTokenId++;
            totalSupply++;
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

        string memory json = string(abi.encodePacked(
            '{"name": "', baseName, ' #', uint2str(tokenId), '",',
            '"description": "', description, '",',
            '"image": "', imageURI, '"}'
        ));

        return string(abi.encodePacked("data:application/json;base64,", base64(bytes(json))));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return ownerOf(tokenId) != address(0);
    }

    // Utility function to convert uint256 to string
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        while (_i != 0) {
            len -= 1;
            bstr[len] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // Utility function to encode in base64
    function base64(bytes memory data) internal pure returns (string memory) {
        string memory TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        string memory result = new string(4 * ((data.length + 2) / 3));
        bytes memory table = bytes(TABLE);

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, mload(data)) {

            } {
                data := add(data, 3)
                let input := mload(data)

                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                mstore(add(resultPtr, 1), shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                mstore(add(resultPtr, 2), shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                mstore(add(resultPtr, 3), shl(248, mload(add(tablePtr, and(input, 0x3F)))))

                resultPtr := add(resultPtr, 4)
            }
        }

        return result;
    }
}
