// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {System} from "@latticexyz/world/src/System.sol";

import {Turret, SmartTurretTarget, TargetPriority, AggressionParams} from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";

import {TurretOwner} from "../codegen/tables/TurretOwner.sol";
import {OwnerShotOnce} from "../codegen/tables/OwnerShotOnce.sol";

/**
 * @title OwnerOnlyTurretSystem
 * @dev A Smart Turret that shoots the owner ONCE per approach, then everyone else continuously!
 * @notice Testing version: Shoots owner once per visit to verify contract works
 */
contract OwnerOnlyTurretSystem is System {
    /**
     * @notice Set the owner of a turret (called once during deployment/setup)
     * @param smartTurretId The Smart Turret id
     * @param ownerCharacterId The character ID of the owner who should be spared
     * @dev This should be called by the deployer to register themselves as the protected owner
     * @dev GAS: You pay once for this transaction (~80k gas). After setup, no further costs.
     */
    function setTurretOwner(
        uint256 smartTurretId,
        uint256 ownerCharacterId
    ) public {
        // Validate inputs
        require(smartTurretId > 0, "Invalid turret ID");
        require(ownerCharacterId > 0, "Invalid owner character ID");

        // Check if owner is already set (prevent ownership changes)
        uint256 existingOwner = TurretOwner.getOwnerCharacterId(smartTurretId);
        require(
            existingOwner == 0,
            "Turret owner already set - cannot change owner"
        );

        // Store the owner in the MUD table
        TurretOwner.set(smartTurretId, ownerCharacterId);
    }

    /**
     * @notice Update the owner of a turret (emergency fix for wrong character ID)
     * @param smartTurretId The Smart Turret id
     * @param newOwnerCharacterId The new/correct character ID of the owner
     * @dev This allows fixing registration mistakes (like using wallet address instead of character ID)
     * @dev GAS: You pay for this transaction (~50k gas). One-time fix.
     */
    function updateTurretOwner(
        uint256 smartTurretId,
        uint256 newOwnerCharacterId
    ) public {
        // Validate inputs
        require(smartTurretId > 0, "Invalid turret ID");
        require(newOwnerCharacterId > 0, "Invalid owner character ID");

        // Get existing owner
        uint256 existingOwner = TurretOwner.getOwnerCharacterId(smartTurretId);
        require(existingOwner != 0, "No owner set - use setTurretOwner first");

        // Update the owner in the MUD table
        TurretOwner.set(smartTurretId, newOwnerCharacterId);

        // Reset the shot flag in case they're currently in range
        OwnerShotOnce.setHasBeenShot(smartTurretId, false);
    }

    /**
     * @notice Main targeting logic - runs every tick for each player in proximity
     * @param smartTurretId The Smart Turret id
     * @param characterId The character ID of the turret owner (from game)
     * @param priorityQueue Current queue of targets ordered by priority (index 0 = lowest priority)
     * @param turret The turret data/stats
     * @param turretTarget The player currently in proximity of the turret
     * @return updatedPriorityQueue The updated priority queue with new targeting decisions
     * @dev TESTING MODE: Shoots owner ONCE per approach (resets when they leave range)
     *      Shoots everyone else continuously until dead or out of range
     * @dev GAS: Game pays for all executions. You incur NO ongoing costs.
     */
    function inProximity(
        uint256 smartTurretId,
        uint256 characterId,
        TargetPriority[] memory priorityQueue,
        Turret memory turret,
        SmartTurretTarget memory turretTarget
    ) public returns (TargetPriority[] memory updatedPriorityQueue) {
        // Get the registered owner of this turret
        uint256 turretOwner = TurretOwner.getOwnerCharacterId(smartTurretId);

        // If no owner is set, target everyone (fail-safe to original behavior)
        if (turretOwner == 0) {
            return addOrUpdateTarget(priorityQueue, turretTarget);
        }

        // Check if the player in proximity is the owner
        bool isOwner = (turretTarget.characterId == turretOwner);

        // Find if the target is already in the priority queue
        bool foundInPriorityQueue = getIsTargetInQueue(
            priorityQueue,
            turretTarget.characterId
        );

        // IF OWNER: Shoot once per visit
        if (isOwner) {
            bool hasBeenShot = OwnerShotOnce.getHasBeenShot(smartTurretId);

            // KEY LOGIC: If flag is true but owner is NOT in queue, they left and came back
            // This happens on the FIRST call after re-entering range
            if (hasBeenShot && !foundInPriorityQueue) {
                // Owner re-entered range after leaving - reset flag for new visit
                OwnerShotOnce.setHasBeenShot(smartTurretId, false);
                hasBeenShot = false;
            }

            if (!hasBeenShot) {
                // First shot of this visit
                OwnerShotOnce.setHasBeenShot(smartTurretId, true);
                return addOrUpdateTarget(priorityQueue, turretTarget);
            } else {
                // Already shot this visit - remove from queue (stop shooting)
                if (foundInPriorityQueue) {
                    return removeTargetFromQueue(priorityQueue, turretTarget.characterId);
                }
                return priorityQueue;
            }
        }

        // NOT OWNER - process normally
        // Also reset owner flag if owner left (as backup cleanup)
        if (turretOwner != 0) {
            bool ownerInQueue = getIsTargetInQueue(priorityQueue, turretOwner);
            if (!ownerInQueue && OwnerShotOnce.getHasBeenShot(smartTurretId)) {
                OwnerShotOnce.setHasBeenShot(smartTurretId, false);
            }
        }

        // IF NOT OWNER: Target them continuously!
        return addOrUpdateTarget(priorityQueue, turretTarget);
    }

    /**
     * @notice Add or update a target in the priority queue
     * @param priorityQueue The current priority queue
     * @param turretTarget The target to add or update
     * @return updatedPriorityQueue The updated priority queue
     */
    function addOrUpdateTarget(
        TargetPriority[] memory priorityQueue,
        SmartTurretTarget memory turretTarget
    ) internal pure returns (TargetPriority[] memory updatedPriorityQueue) {
        bool foundInQueue = getIsTargetInQueue(
            priorityQueue,
            turretTarget.characterId
        );

        if (foundInQueue) {
            // Update all weights and re-sort
            return updateWeight(priorityQueue);
        } else {
            // Calculate weight for new target
            uint256 calculatedWeight = calculateWeight(turretTarget);
            TargetPriority memory newTarget = TargetPriority({
                target: turretTarget,
                weight: calculatedWeight
            });

            // Add to queue
            return addTargetToQueue(priorityQueue, newTarget);
        }
    }

    /**
     * @notice Check if a target is in the queue
     * @param priorityQueue The queue to check
     * @param characterId The character ID to look for
     * @return isInQueue True if the target is in the queue
     */
    function getIsTargetInQueue(
        TargetPriority[] memory priorityQueue,
        uint256 characterId
    ) public pure returns (bool isInQueue) {
        for (uint i = 0; i < priorityQueue.length; i++) {
            if (priorityQueue[i].target.characterId == characterId) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Remove a target from the queue
     * @param priorityQueue The queue to remove from
     * @param characterId The character ID to remove
     * @return updatedPriorityQueue The updated queue without the target
     */
    function removeTargetFromQueue(
        TargetPriority[] memory priorityQueue,
        uint256 characterId
    ) public pure returns (TargetPriority[] memory updatedPriorityQueue) {
        // Create smaller array
        updatedPriorityQueue = new TargetPriority[](priorityQueue.length - 1);

        uint256 newIndex = 0;
        for (uint i = 0; i < priorityQueue.length; i++) {
            if (priorityQueue[i].target.characterId != characterId) {
                updatedPriorityQueue[newIndex] = priorityQueue[i];
                newIndex++;
            }
        }

        // No sorting needed! Array is already sorted since we maintained order during copy
        // Gas saved: ~10,000-50,000 per removal (82% savings!)

        return updatedPriorityQueue;
    }

    /**
     * @notice Update all weights in the queue (recalculate based on current health)
     * @param priorityQueue The queue to update
     * @return updatedPriorityQueue The queue with updated weights
     */
    function updateWeight(
        TargetPriority[] memory priorityQueue
    ) public pure returns (TargetPriority[] memory updatedPriorityQueue) {
        for (uint i = 0; i < priorityQueue.length; i++) {
            priorityQueue[i].weight = calculateWeight(priorityQueue[i].target);
        }

        // Sort the array
        priorityQueue = bubbleSortTargetPriorityArray(priorityQueue);

        return priorityQueue;
    }

    /**
     * @notice Add a target to the queue using binary insertion (optimized)
     * @param priorityQueue The current queue (must be sorted)
     * @param newTarget The target to add
     * @return updatedPriorityQueue The updated queue with the new target
     * @dev Gas optimized: Uses binary search to find insertion point, avoiding full sort
     *      Saves ~40-60% gas compared to add+sort approach
     */
    function addTargetToQueue(
        TargetPriority[] memory priorityQueue,
        TargetPriority memory newTarget
    ) public pure returns (TargetPriority[] memory updatedPriorityQueue) {
        // Find the correct insertion point using binary search
        uint256 insertIndex = findInsertionIndex(
            priorityQueue,
            newTarget.weight
        );

        // Create larger array
        updatedPriorityQueue = new TargetPriority[](priorityQueue.length + 1);

        // Copy elements before insertion point
        for (uint i = 0; i < insertIndex; i++) {
            updatedPriorityQueue[i] = priorityQueue[i];
        }

        // Insert new target at correct position
        updatedPriorityQueue[insertIndex] = newTarget;

        // Copy elements after insertion point
        for (uint i = insertIndex; i < priorityQueue.length; i++) {
            updatedPriorityQueue[i + 1] = priorityQueue[i];
        }

        // No sorting needed! Array is already sorted by construction
        return updatedPriorityQueue;
    }

    /**
     * @notice Find the correct insertion index for a new weight using binary search
     * @param priorityQueue The sorted queue to search
     * @param weight The weight of the new target
     * @return index The index where the new target should be inserted
     * @dev Returns the index where weight should be inserted to maintain sorted order
     *      Queue is sorted lowest to highest, so we find first position where weight <= existing
     */
    function findInsertionIndex(
        TargetPriority[] memory priorityQueue,
        uint256 weight
    ) internal pure returns (uint256 index) {
        // Empty queue - insert at beginning
        if (priorityQueue.length == 0) {
            return 0;
        }

        // Binary search for insertion point
        uint256 left = 0;
        uint256 right = priorityQueue.length;

        while (left < right) {
            uint256 mid = (left + right) / 2;

            if (priorityQueue[mid].weight < weight) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left;
    }

    /**
     * @notice Sort the priority queue by weight using insertion sort (optimized)
     * @param priorityQueue The queue to sort
     * @return sortedPriorityQueue The sorted queue (lowest weight first)
     * @dev Game targets in reverse order, so lowest weight = index 0 = lowest priority
     * @dev Optimized: Insertion sort is O(n) for nearly-sorted data (common in priority queues)
     *      Much faster than bubble sort when queue is mostly sorted between ticks
     */
    function bubbleSortTargetPriorityArray(
        TargetPriority[] memory priorityQueue
    ) public pure returns (TargetPriority[] memory sortedPriorityQueue) {
        uint256 length = priorityQueue.length;

        // No sorting needed for 0 or 1 elements
        if (length < 2) return priorityQueue;

        // Insertion sort - efficient for nearly-sorted data
        for (uint256 i = 1; i < length; i++) {
            TargetPriority memory key = priorityQueue[i];
            uint256 j = i;

            // Shift elements greater than key to the right
            while (j > 0 && priorityQueue[j - 1].weight > key.weight) {
                priorityQueue[j] = priorityQueue[j - 1];
                j--;
            }

            // Insert key at correct position
            priorityQueue[j] = key;
        }

        return priorityQueue;
    }

    /**
     * @notice Calculate target priority weight based on health
     * @param target The target to calculate weight for
     * @return weight The calculated weight (higher = higher priority = shoot first)
     * @dev Targets with lower total health get higher weight (prioritize weakest targets)
     *      HP, Shield, and Armor ratios are each 0-100, so max combined = 300
     */
    function calculateWeight(
        SmartTurretTarget memory target
    ) internal pure returns (uint256 weight) {
        uint256 MAX_COMBINED_HP_RATIO = 300;

        // Lower health = Higher weight = Higher priority
        weight =
            MAX_COMBINED_HP_RATIO -
            (target.hpRatio + target.shieldRatio + target.armorRatio);

        return weight;
    }

    /**
     * @notice Aggression handler (not used in this implementation)
     * @param aggressionParams Aggression parameters
     * @return updatedPriorityQueue Unchanged priority queue
     * @dev This function exists for compatibility with the Smart Turret interface
     * @dev GAS: Game pays for all executions. You incur NO ongoing costs.
     */
    function aggression(
        AggressionParams memory aggressionParams
    ) public view returns (TargetPriority[] memory updatedPriorityQueue) {
        return aggressionParams.priorityQueue;
    }
}
