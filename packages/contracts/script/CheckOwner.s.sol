// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";

import {TurretOwner} from "../src/codegen/tables/TurretOwner.sol";
import {OwnerShotOnce} from "../src/codegen/tables/OwnerShotOnce.sol";

/**
 * @notice Check what's stored for the turret owner
 */
contract CheckOwner is Script {
    function run(address worldAddress) external {
        StoreSwitch.setStoreAddress(worldAddress);

        uint256 turretId = vm.envUint("TURRET_ID");

        console.log("=== Turret Owner Check ===");
        console.log("Turret ID:", vm.toString(turretId));

        uint256 ownerId = TurretOwner.getOwnerCharacterId(turretId);
        console.log(
            "Registered Owner Character ID (uint256):",
            vm.toString(ownerId)
        );
        console.log(
            "Registered Owner (as address):",
            address(uint160(ownerId))
        );

        bool hasBeenShot = OwnerShotOnce.getHasBeenShot(turretId);
        console.log("Owner Shot Flag:", hasBeenShot);
    }
}
