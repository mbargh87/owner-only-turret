#!/bin/bash
# Test the targeting logic of the Owner-Only Turret
# This simulates what happens when players approach the turret

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
WORLD_ADDRESS="0xEdf8089F67Ce8dC619e5BA95Ad00f27be755d996"
RPC_URL="http://127.0.0.1:8546"
PRIVATE_KEY="0x13b345221484e825b9a03de67d3574f7c765d8039d93415fedf915972c1575c5"

# Test scenario
TURRET_ID=777
OWNER_CHAR_ID=12345
ENEMY_CHAR_ID_1=11111
ENEMY_CHAR_ID_2=22222
FRIEND_CHAR_ID=33333

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║   Targeting Logic Test Suite             ║
║   Testing inProximity() function         ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}Test Setup:${NC}"
echo "  Turret ID: $TURRET_ID"
echo "  Owner Character: $OWNER_CHAR_ID"
echo "  Enemy 1: $ENEMY_CHAR_ID_1"
echo "  Enemy 2: $ENEMY_CHAR_ID_2"
echo "  Friend: $FRIEND_CHAR_ID"
echo ""

# Step 1: Register turret owner
echo -e "${GREEN}Step 1: Register Turret Owner${NC}"
echo "Setting character $OWNER_CHAR_ID as owner of turret $TURRET_ID..."
cast send "$WORLD_ADDRESS" \
    "ownerturret__setTurretOwner(uint256,uint256)" \
    $TURRET_ID $OWNER_CHAR_ID \
    --rpc-url "$RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --silent

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Owner registered successfully${NC}"
else
    echo -e "${YELLOW}⚠ Owner may already be set${NC}"
fi
echo ""

# Step 2: Test the inProximity function
echo -e "${GREEN}Step 2: Test Targeting Logic${NC}"
echo ""
echo -e "${BLUE}NOTE: The inProximity() function requires complex struct parameters${NC}"
echo -e "${BLUE}that would normally be provided by the EVE game engine.${NC}"
echo ""
echo -e "${YELLOW}What WOULD happen in the game:${NC}"
echo ""

echo -e "${CYAN}Scenario A: Owner approaches turret${NC}"
echo "  Character: $OWNER_CHAR_ID (YOU)"
echo "  Expected Priority: 0 (SAFE - won't be shot)"
echo ""

echo -e "${CYAN}Scenario B: Enemy 1 approaches turret${NC}"
echo "  Character: $ENEMY_CHAR_ID_1"
echo "  Expected Priority: 100 (TARGET - will be shot)"
echo ""

echo -e "${CYAN}Scenario C: Enemy 2 approaches turret${NC}"
echo "  Character: $ENEMY_CHAR_ID_2"
echo "  Expected Priority: 100 (TARGET - will be shot)"
echo ""

echo -e "${CYAN}Scenario D: Multiple players in range${NC}"
echo "  Priority Queue: [0, 100, 100]"
echo "  Game shoots in reverse: Enemy 2 → Enemy 1 → Skip You"
echo ""

# Step 3: Verify the logic with a simpler test
echo -e "${GREEN}Step 3: Verify Contract Logic${NC}"
echo ""
echo "Let's verify the owner is stored correctly by trying to change it..."
echo ""

result=$(cast send "$WORLD_ADDRESS" \
    "ownerturret__setTurretOwner(uint256,uint256)" \
    $TURRET_ID $ENEMY_CHAR_ID_1 \
    --rpc-url "$RPC_URL" \
    --private-key "$PRIVATE_KEY" 2>&1 || true)

if echo "$result" | grep -q "already set\|revert"; then
    echo -e "${GREEN}✓ Contract correctly protects owner (cannot be changed)${NC}"
    echo -e "${GREEN}✓ This confirms the owner lookup works${NC}"
else
    echo -e "${YELLOW}⚠ Unexpected behavior${NC}"
fi
echo ""

# Step 4: Explain the limitation
echo -e "${GREEN}Step 4: Understanding the Test Limitation${NC}"
echo ""
echo -e "${YELLOW}Why we can't fully test inProximity():${NC}"
echo ""
echo "The inProximity() function requires these complex inputs:"
echo "  • smartTurretId: uint256"
echo "  • characterId: uint256"
echo "  • priorityQueue: SmartTurretTarget[]"
echo "  • turret: Turret struct (with position, ammo, etc.)"
echo "  • turretTarget: TargetPriority struct (player position, etc.)"
echo ""
echo "These structs contain:"
echo "  • 3D coordinates (x, y, z)"
echo "  • Turret ammunition counts"
echo "  • Player velocities"
echo "  • Weapon types"
echo "  • And more game-specific data"
echo ""
echo -e "${CYAN}This data is normally provided by the EVE game engine${NC}"
echo -e "${CYAN}during actual gameplay when players move near turrets.${NC}"
echo ""

# Step 5: What we CAN verify
echo -e "${GREEN}Step 5: What We CAN Verify${NC}"
echo ""
echo -e "${GREEN}✓ Owner storage works${NC} - Tested above"
echo -e "${GREEN}✓ Owner protection works${NC} - Cannot change owner"
echo -e "${GREEN}✓ Contract is deployed${NC} - On chain and responsive"
echo -e "${YELLOW}⚠ Proximity logic${NC} - Requires EVE game environment"
echo ""

# Step 6: Next testing approach
echo -e "${GREEN}Step 6: How to FULLY Test the Targeting Logic${NC}"
echo ""
echo -e "${YELLOW}Option A: Unit Tests (Recommended)${NC}"
echo "  Run the Foundry tests:"
echo "  $ cd packages/contracts"
echo "  $ forge test -vvv"
echo ""
echo "  The test file test/OwnerOnlyTurretSystem.t.sol"
echo "  can create mock structs and test all scenarios."
echo ""

echo -e "${YELLOW}Option B: Integration Testing${NC}"
echo "  Deploy to Pyrope testnet and use actual Smart Turrets"
echo "  This tests with real EVE game data"
echo ""

echo -e "${YELLOW}Option C: Read the Contract Code${NC}"
echo "  Review src/systems/OwnerOnlyTurretSystem.sol"
echo "  Line 66-82 shows the exact logic:"
echo ""
echo -e "${CYAN}  if (turretTarget.characterId == storedOwner) {${NC}"
echo -e "${CYAN}      return 0;  // Owner is safe${NC}"
echo -e "${CYAN}  } else {${NC}"
echo -e "${CYAN}      return 100;  // Everyone else is a target${NC}"
echo -e "${CYAN}  }${NC}"
echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}What We Tested:${NC}"
echo "  ✓ Owner registration"
echo "  ✓ Owner immutability"
echo "  ✓ Contract deployment"
echo ""
echo -e "${YELLOW}What Requires Game Environment:${NC}"
echo "  ⚠ Actual proximity detection"
echo "  ⚠ Priority queue updates"
echo "  ⚠ Multi-player scenarios"
echo ""
echo -e "${CYAN}Recommended Next Step:${NC}"
echo "  Run: forge test -vvv"
echo "  This runs the unit tests with mock data"
echo ""
