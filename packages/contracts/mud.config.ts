import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "ownerturret", // Unique namespace for our turret
  tables: {
    TurretOwner: {
      schema: {
        smartTurretId: "uint256",  // Which turret
        ownerCharacterId: "uint256" // Who owns it (their character ID)
      },
      key: ["smartTurretId"], // Key by turret ID (each turret has one owner)
    },
    OwnerShotOnce: {
      schema: {
        smartTurretId: "uint256",  // Which turret
        hasBeenShot: "bool"        // Has the owner been shot once already?
      },
      key: ["smartTurretId"], // Key by turret ID
    }
  },
});
