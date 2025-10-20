// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";

import {SmartTurretSystem, smartTurretSystem} from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartTurretSystemLib.sol";

import {Utils} from "../src/systems/Utils.sol";

/**
 * @notice Configure the turret to use our custom system
 * @dev This must be called by the turret owner to enable custom targeting logic
 */
contract ConfigureTurret is Script {
    function run(address worldAddress) external {
        StoreSwitch.setStoreAddress(worldAddress);
        IBaseWorld world = IBaseWorld(worldAddress);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 turretId = vm.envUint("TURRET_ID");

        console.log("Configuring turret:", vm.toString(turretId));

        ResourceId systemId = Utils.ownerOnlyTurretSystemId();
        console.log("System ID:", vm.toString(ResourceId.unwrap(systemId)));

        // This function can only be called by the owner of the smart turret
        // It tells the turret to use our custom targeting system
        smartTurretSystem.configureTurret(turretId, systemId);

        console.log("Turret configured successfully!");
        console.log(
            "The turret will now use OwnerOnlyTurretSystem for targeting"
        );

        vm.stopBroadcast();
    }
}
