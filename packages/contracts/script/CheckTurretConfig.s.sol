// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";

import {SmartTurretConfig} from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/SmartTurretConfig.sol";

/**
 * @notice Check what system the turret is configured to use
 */
contract CheckTurretConfig is Script {
    function run(address worldAddress) external {
        StoreSwitch.setStoreAddress(worldAddress);

        uint256 turretId = vm.envUint("TURRET_ID");

        console.log("=== Turret Configuration Check ===");
        console.log("Turret ID:", vm.toString(turretId));

        ResourceId configuredSystemId = SmartTurretConfig.get(turretId);
        console.log(
            "Configured System ID:",
            vm.toString(ResourceId.unwrap(configuredSystemId))
        );

        bytes32 expectedSystemId = 0x73796f776e65727475727265740000004f776e65724f6e6c7954757272657453;
        console.log("Expected System ID: ", vm.toString(expectedSystemId));

        if (ResourceId.unwrap(configuredSystemId) == expectedSystemId) {
            console.log(
                "Status: CORRECT - Turret is using OwnerOnlyTurretSystem!"
            );
        } else if (ResourceId.unwrap(configuredSystemId) == bytes32(0)) {
            console.log(
                "Status: ERROR - Turret has NO custom system configured!"
            );
        } else {
            console.log(
                "Status: WARNING - Turret is using a DIFFERENT system!"
            );
        }
    }
}
