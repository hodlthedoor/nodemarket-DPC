// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EarlyAccessNodemarketPass} from "src/EANMP.sol";

contract DeployEarlyAccessPassScript is Script {
    function setUp() public {}

    // forge script script/DeployEarlyAccessPass.s.sol:DeployEarlyAccessPassScript --private-key $PRIVATE_KEY --rpc-url $RPC_URL --verify --etherscan-api-key $API_KEY --legacy --broadcast -vv

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory _name = "Nodemarket Early Access Pass";
        string memory _symbol = "NEAP";
        string memory _baseName = "Nodemarket Early Access Pass";
        string memory _description = "Nodemarket Early Access Pass";
        string memory _imageURI = "";

        EarlyAccessNodemarketPass eap =
            new EarlyAccessNodemarketPass(_name, _symbol, _baseName, _description, _imageURI);

        console.log("Deployed Nodemarket early access pass at address: ", address(eap));

        address nyteowl = address(0xe4d1eA980E9e79E7853EB6CE6D2CDaeddE40c263);

        eap.transferOwnership(nyteowl);

        vm.stopBroadcast();
    }
}
