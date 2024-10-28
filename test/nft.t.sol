// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "src/DPC.sol";

contract DPCTest is Test {
    DPC public nft;
    address public owner;
    address public user1;
    address public user2;

    // Test variables
    string constant NAME = "Digital Pet Companions";
    string constant SYMBOL = "DPC";
    string constant BASE_NAME = "Digital Pet";
    string constant DESCRIPTION = "A lovely digital pet companion";
    string constant IMAGE_URI = "ipfs://QmExample";

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        vm.startPrank(owner);
        nft = new DPC(
            NAME,
            SYMBOL,
            BASE_NAME,
            DESCRIPTION,
            IMAGE_URI
        );
        vm.stopPrank();
    }

    function test_InitialState() public {
        assertEq(nft.name(), NAME);
        assertEq(nft.symbol(), SYMBOL);
        assertEq(nft.baseName(), BASE_NAME);
        assertEq(nft.description(), DESCRIPTION);
        assertEq(nft.imageURI(), IMAGE_URI);
        assertEq(nft.currentTokenId(), 0);
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.owner(), owner);
    }

    function test_Mint() public {
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;

        vm.prank(owner);
        nft.mint(recipients);

        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.currentTokenId(), 2);
        assertEq(nft.totalSupply(), 2);
    }

    function testFail_MintNotOwner() public {
        address[] memory recipients = new address[](1);
        recipients[0] = user1;

        vm.prank(user1);
        nft.mint(recipients);
    }

    function test_Burn() public {
        // First mint a token
        address[] memory recipients = new address[](1);
        recipients[0] = user1;
        
        vm.prank(owner);
        nft.mint(recipients);
        
        // Test burning by token owner
        vm.prank(user1);
        nft.burn(0);
        
        assertEq(nft.totalSupply(), 0);
        vm.expectRevert();
        nft.ownerOf(0);
    }

    function test_BurnByOwner() public {
        // First mint a token
        address[] memory recipients = new address[](1);
        recipients[0] = user1;
        
        vm.prank(owner);
        nft.mint(recipients);
        
        // Test burning by contract owner
        vm.prank(owner);
        nft.burn(0);
        
        assertEq(nft.totalSupply(), 0);
        vm.expectRevert();
        nft.ownerOf(0);
    }

    function testFail_BurnUnauthorized() public {
        // First mint a token
        address[] memory recipients = new address[](1);
        recipients[0] = user1;
        
        vm.prank(owner);
        nft.mint(recipients);
        
        // Try burning from unauthorized address
        vm.prank(user2);
        nft.burn(0);
    }

    function test_UpdateImageURI() public {
        string memory newURI = "ipfs://QmNewExample";
        
        vm.prank(owner);
        nft.updateImageURI(newURI);
        
        assertEq(nft.imageURI(), newURI);
    }

    function testFail_UpdateImageURINotOwner() public {
        string memory newURI = "ipfs://QmNewExample";
        
        vm.prank(user1);
        nft.updateImageURI(newURI);
    }

    function test_TokenURI() public {
        // First mint a token
        address[] memory recipients = new address[](1);
        recipients[0] = user1;
        
        vm.prank(owner);
        nft.mint(recipients);
        
        string memory expectedURI = string(
            abi.encodePacked(
                'data:application/json;utf8,{"name": "',
                BASE_NAME,
                " #",
                "0",
                '",',
                '"description": "',
                DESCRIPTION,
                '",',
                '"image": "',
                IMAGE_URI,
                '"}'
            )
        );
        
        assertEq(nft.tokenURI(0), expectedURI);
    }

    function testFail_TokenURIForNonexistentToken() public {
        nft.tokenURI(0);
    }

    function test_BatchMint(uint8 numRecipients) public {
        vm.assume(numRecipients > 0);
        
        address[] memory recipients = new address[](numRecipients);
        for(uint8 i = 0; i < numRecipients; i++) {
            recipients[i] = makeAddr(string.concat("user", vm.toString(i)));
        }
        
        vm.prank(owner);
        nft.mint(recipients);
        
        assertEq(nft.totalSupply(), numRecipients);
        assertEq(nft.currentTokenId(), numRecipients);
        
        // Verify each token was minted to the correct recipient
        for(uint8 i = 0; i < numRecipients; i++) {
            assertEq(nft.ownerOf(i), recipients[i]);
        }
    }
}