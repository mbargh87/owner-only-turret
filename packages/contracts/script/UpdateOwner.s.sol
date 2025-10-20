// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";

import {Utils} from "../src/systems/Utils.sol";
import {OwnerOnlyTurretSystem} from "../src/systems/OwnerOnlyTurretSystem.sol";

/**
 * @notice Update turret owner to the correct character ID
 */
contract UpdateOwner is Script {
    function run(address worldAddress) external {
        StoreSwitch.setStoreAddress(worldAddress);
        IBaseWorld world = IBaseWorld(worldAddress);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 turretId = vm.envUint("TURRET_ID");
        uint256 characterId = vm.envUint("CHARACTER_ID");

        console.log("Updating turret owner...");
        console.log("Turret ID:", vm.toString(turretId));
        console.log("New Character ID:", vm.toString(characterId));

        ResourceId systemId = Utils.ownerOnlyTurretSystemId();

        world.call(
            systemId,
            abi.encodeCall(
                OwnerOnlyTurretSystem.updateTurretOwner,
                (turretId, characterId)
            )
        );

        console.log("Owner updated successfully!");

        vm.stopBroadcast();
    }
}
