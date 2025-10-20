#!/bin/bash

# Register turret owner via CLI
# Usage: ./register-owner.sh <turretId> <ownerAddress>

TURRET_ID=$1
OWNER_ADDRESS=$2

if [ -z "$TURRET_ID" ] || [ -z "$OWNER_ADDRESS" ]; then
    echo "Usage: ./register-owner.sh <turretId> <ownerAddress>"
    echo ""
    echo "Example:"
    echo "  ./register-owner.sh 44973507583497126349853277567784089051534402655779934255490424747595261704481 0x24ab469C82F857a2d3C7b4997840EaEC4FCBE998"
    exit 1
fi

# Load environment
source .env

echo "🎯 Registering Turret Owner"
echo "=============================="
echo "Turret ID:      $TURRET_ID"
echo "Owner Address:  $OWNER_ADDRESS"
echo "World Address:  $WORLD_ADDRESS"
echo "RPC:            $RPC_URL"
echo ""

# System ID for OwnerOnlyTurretSystem
SYSTEM_ID="0x73796f776e65727475727265740000004f776e65724f6e6c7954757272657453"

echo "Calling setTurretOwner($TURRET_ID, $OWNER_ADDRESS)..."
echo ""

# Call the World.call() function with our system ID
cast send $WORLD_ADDRESS \
    "call(bytes32,bytes)" \
    "$SYSTEM_ID" \
    "$(cast calldata 'setTurretOwner(uint256,uint256)' $TURRET_ID $OWNER_ADDRESS)" \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY

echo ""
echo "✅ Registration transaction sent!"
echo ""
echo "Now approach your turret in-game to test the contract!"
