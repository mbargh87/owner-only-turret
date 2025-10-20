#!/bin/bash

# Check if a turret owner is registered
# Usage: ./check-owner.sh <turretId>

TURRET_ID=$1

if [ -z "$TURRET_ID" ]; then
    echo "Usage: ./check-owner.sh <turretId>"
    exit 1
fi

# Load environment
source .env

echo "Checking owner for turret ID: $TURRET_ID"
echo "World Address: $WORLD_ADDRESS"
echo "RPC: $RPC_URL"
echo ""

# Query the TurretOwner table
# Table ID for TurretOwner in namespace "ownerturret"
cast call $WORLD_ADDRESS \
    "getRecord(bytes32,bytes32[],bytes32)" \
    "0x74626f776e65727475727265740000000000000000005475727265744f776e6572" \
    "[$TURRET_ID]" \
    "0x6f776e65724368617261637465724964000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" \
    --rpc-url $RPC_URL

echo ""
echo "If you see a non-zero value, the owner is registered!"
