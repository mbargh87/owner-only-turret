// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";

import {CharactersByAccount} from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/CharactersByAccount.sol";

/**
 * @notice Check what character ID is associated with an address
 */
contract CheckCharacterId is Script {
    function run(address worldAddress) external {
        StoreSwitch.setStoreAddress(worldAddress);

        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        console.log("=== Character ID Lookup ===");
        console.log("Wallet Address:", walletAddress);

        uint256 characterId = CharactersByAccount.get(walletAddress);

        if (characterId == 0) {
            console.log(
                "Character ID: NONE - No character associated with this address!"
            );
            console.log("You might need to create a character in-game first!");
        } else {
            console.log("Character ID:", vm.toString(characterId));
            console.log(
                "Character ID (as address):",
                address(uint160(characterId))
            );
        }

        // Also show what was registered as owner
        console.log("");
        console.log(
            "What you registered as owner:",
            vm.toString(uint256(uint160(walletAddress)))
        );
    }
}
