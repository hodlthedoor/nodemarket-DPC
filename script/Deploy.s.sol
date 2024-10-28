// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DPC} from "src/DPC.sol";

contract DeployScript is Script {

    function setUp() public {}

    // forge script script/Deploy.s.sol:DeployScript --private-key $PRIVATE_KEY --rpc-url $RPC_URL --verify --etherscan-api-key $API_KEY --legacy --broadcast -vv
   
    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");       
        vm.startBroadcast(deployerPrivateKey);

        string memory _name = "Digital Private Client";
        string memory _symbol = "DPC";
        string memory _baseName = "Digital Private Client";
        string memory _description = "Digital Private Client";
        string memory _imageURI = "https://bafybeihm3vcr3r4pgpe5r43zoxbs7abf55i6qypdwdsqkezkqoyyu3gx6y.ipfs.web3approved.com/?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaWQiOiJiYWZ5YmVpaG0zdmNyM3I0cGdwZTVyNDN6b3hiczdhYmY1NWk2cXlwZHdkc3FrZXprcW95eXUzZ3g2eSIsInByb2plY3RfdXVpZCI6IjMyYzJhYmJmLTA2YTMtNGY0YS1iMzc4LTExZjYxNWE3YThjMyIsImlhdCI6MTcyNjY1ODE0MCwic3ViIjoiSVBGUy10b2tlbiJ9.R3E9N40dUhn94MfhMHpEAaDqMNCHQZmhW081IaeimJc";

        DPC dpc = new DPC(_name, _symbol, _baseName, _description, _imageURI);


        console.log("Deployed NodemarketDPC contract at address: ", address(dpc));

        address nyteowl = address(0xe4d1eA980E9e79E7853EB6CE6D2CDaeddE40c263);

        dpc.transferOwnership(nyteowl);

        

        vm.stopBroadcast();
    }
}
