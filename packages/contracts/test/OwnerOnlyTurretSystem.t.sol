// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { OwnerOnlyTurretSystem } from "../src/systems/OwnerOnlyTurretSystem.sol";
import { 
  Turret, 
  SmartTurretTarget, 
  TargetPriority 
} from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";

/**
 * @title OwnerOnlyTurretSystemTest
 * @dev Test suite for the Owner-Only Turret system
 * @notice Tests the pure logic functions without requiring MUD store setup
 */
contract OwnerOnlyTurretSystemTest is Test {
  OwnerOnlyTurretSystem public turretSystem;
  
  // Test constants
  uint256 constant TURRET_ID = 1;
  uint256 constant OWNER_CHAR_ID = 100;
  uint256 constant ENEMY_CHAR_ID_1 = 200;
  uint256 constant ENEMY_CHAR_ID_2 = 300;
  uint256 constant ENEMY_CHAR_ID_3 = 400;
  
  function setUp() public {
    // Deploy the system
    turretSystem = new OwnerOnlyTurretSystem();
  }
  
  // ============ REMOVED OWNER REGISTRATION TESTS ============
  // Note: Owner registration tests require MUD World/Store setup
  // These would be tested in integration tests with a full MUD deployment
  
  // ============ QUEUE MANAGEMENT TESTS ============
  
  function test_GetIsTargetInQueue_Found() public {
    // Create a queue with a target
    SmartTurretTarget memory target = createTarget(ENEMY_CHAR_ID_1, 100, 100, 100);
    TargetPriority[] memory queue = new TargetPriority[](1);
    queue[0] = TargetPriority({ target: target, weight: 0 });
    
    // Check if target is in queue
    bool found = turretSystem.getIsTargetInQueue(queue, ENEMY_CHAR_ID_1);
    assertTrue(found, "Target should be found in queue");
  }
  
  function test_GetIsTargetInQueue_NotFound() public {
    // Create a queue with a target
    SmartTurretTarget memory target = createTarget(ENEMY_CHAR_ID_1, 100, 100, 100);
    TargetPriority[] memory queue = new TargetPriority[](1);
    queue[0] = TargetPriority({ target: target, weight: 0 });
    
    // Check if different target is in queue
    bool found = turretSystem.getIsTargetInQueue(queue, ENEMY_CHAR_ID_2);
    assertFalse(found, "Different target should not be found in queue");
  }
  
  function test_RemoveTargetFromQueue_Success() public {
    // Create queue with 3 targets
    TargetPriority[] memory queue = new TargetPriority[](3);
    queue[0] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_1, 100, 100, 100), weight: 0 });
    queue[1] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_2, 50, 50, 50), weight: 150 });
    queue[2] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_3, 10, 10, 10), weight: 270 });
    
    // Remove middle target
    TargetPriority[] memory result = turretSystem.removeTargetFromQueue(queue, ENEMY_CHAR_ID_2);
    
    // Should have 2 targets left
    assertEq(result.length, 2, "Should have 2 targets after removal");
    
    // Verify the removed target is not present
    bool found = turretSystem.getIsTargetInQueue(result, ENEMY_CHAR_ID_2);
    assertFalse(found, "Removed target should not be in queue");
    
    // Other targets should still be present
    assertTrue(turretSystem.getIsTargetInQueue(result, ENEMY_CHAR_ID_1), "Other targets should remain");
    assertTrue(turretSystem.getIsTargetInQueue(result, ENEMY_CHAR_ID_3), "Other targets should remain");
  }
  
  function test_BubbleSortTargetPriorityArray_SortsCorrectly() public {
    // Create unsorted queue (weights: 150, 0, 270)
    TargetPriority[] memory queue = new TargetPriority[](3);
    queue[0] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_2, 50, 50, 50), weight: 150 });
    queue[1] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_1, 100, 100, 100), weight: 0 });
    queue[2] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_3, 10, 10, 10), weight: 270 });
    
    // Sort
    TargetPriority[] memory sorted = turretSystem.bubbleSortTargetPriorityArray(queue);
    
    // Verify sorted order: 0, 150, 270 (ascending)
    assertEq(sorted[0].weight, 0, "First should have weight 0");
    assertEq(sorted[1].weight, 150, "Second should have weight 150");
    assertEq(sorted[2].weight, 270, "Third should have weight 270");
    
    // Verify character IDs are in correct order
    assertEq(sorted[0].target.characterId, ENEMY_CHAR_ID_1);
    assertEq(sorted[1].target.characterId, ENEMY_CHAR_ID_2);
    assertEq(sorted[2].target.characterId, ENEMY_CHAR_ID_3);
  }
  
  function test_AddTargetToQueue_SortsCorrectly() public {
    // Create queue with 2 targets (weights: 0, 270)
    TargetPriority[] memory queue = new TargetPriority[](2);
    queue[0] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_1, 100, 100, 100), weight: 0 });
    queue[1] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_3, 10, 10, 10), weight: 270 });
    
    // Add new target with weight 150 (middle priority)
    TargetPriority memory newTarget = TargetPriority({
      target: createTarget(ENEMY_CHAR_ID_2, 50, 50, 50),
      weight: 150
    });
    
    TargetPriority[] memory result = turretSystem.addTargetToQueue(queue, newTarget);
    
    // Should have 3 targets
    assertEq(result.length, 3, "Should have 3 targets");
    
    // Verify sorted order: 0, 150, 270
    assertEq(result[0].weight, 0);
    assertEq(result[1].weight, 150);
    assertEq(result[2].weight, 270);
  }
  
  function test_UpdateWeight_RecalculatesAllWeights() public {
    // Create queue with targets at specific health levels
    TargetPriority[] memory queue = new TargetPriority[](2);
    queue[0] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_1, 100, 100, 100), weight: 999 }); // Wrong weight
    queue[1] = TargetPriority({ target: createTarget(ENEMY_CHAR_ID_2, 50, 50, 50), weight: 999 }); // Wrong weight
    
    // Update weights
    TargetPriority[] memory result = turretSystem.updateWeight(queue);
    
    // Verify weights were recalculated correctly
    assertEq(result[0].weight, 0, "Weight should be recalculated to 0");
    assertEq(result[1].weight, 150, "Weight should be recalculated to 150");
  }
  
  // ============ INTEGRATION TESTS ============
  // Note: These would require full MUD World setup for proper testing
  // For now we test the pure logic functions
  
  // ============ HELPER FUNCTIONS ============
  
  function createTarget(
    uint256 characterId,
    uint256 hpRatio,
    uint256 shieldRatio,
    uint256 armorRatio
  ) internal pure returns (SmartTurretTarget memory) {
    return SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: characterId,
      hpRatio: hpRatio,
      shieldRatio: shieldRatio,
      armorRatio: armorRatio
    });
  }
  
  function createDummyTurret() internal pure returns (Turret memory) {
    return Turret({
      weaponTypeId: 1,
      ammoTypeId: 1,
      chargesLeft: 100
    });
  }
}
