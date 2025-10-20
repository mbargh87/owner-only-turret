# 🎯 Owner-Only Turret

A Smart Turret contract for EVE Frontier that shoots the owner ONCE per visit, then continuously shoots everyone else!

## 🌐 Live DApp

**URL**: https://mbargh87.github.io/owner-only-turret/

## 📋 What It Does

- **Owner**: Gets shot once per visit (resets when leaving range)
- **Everyone else**: Gets shot continuously until dead or out of range
- **Gas efficient**: Uses binary search insertion and optimized storage

## 🚀 Quick Start

1. Visit the DApp URL
2. Connect your EVE Vault wallet
3. Enter your turret's Smart Object ID
4. Click "Register as Owner"
5. The DApp will automatically:
   - Register you as the turret owner
   - Configure the turret to use the custom targeting system
6. Approach your turret in-game to test!

## 🔧 Deployment Info

- **Network**: Pyrope Testnet (Chain ID: 695569)
- **World Address**: `0x7b71fe480ac4E7E96d150A1454411c5CBFb2B1F1`
- **System ID**: `0x73796f776e65727475727265740000004f776e65724f6e6c7954757272657453`
- **Namespace**: `ownerturret`
- **Deployed Block**: 9699122

## 📖 How It Works

### 1. Registration
When you click "Register as Owner", two things happen:

**Transaction 1**: Register ownership
```solidity
setTurretOwner(uint256 smartTurretId, uint256 ownerCharacterId)
```
- Stores your wallet address as the turret owner
- One-time setup, cannot be changed later

**Transaction 2**: Configure turret
```solidity
configureTurret(uint256 smartObjectId, ResourceId systemId)
```
- Tells the turret to use `OwnerOnlyTurretSystem` for targeting
- Activates the custom logic

### 2. In-Game Behavior
Once configured, the game engine calls your contract every tick:

```solidity
function inProximity(
    uint256 smartTurretId,
    uint256 characterId,
    TargetPriority[] memory priorityQueue,
    Turret memory turret,
    SmartTurretTarget memory turretTarget
) public returns (TargetPriority[] memory)
```

The contract:
1. Checks if the player is the registered owner
2. If owner and not shot yet → Add to queue (shoot once)
3. If owner and already shot → Remove from queue (safe)
4. If not owner → Add to queue (shoot continuously)
5. Resets the "shot flag" when owner leaves range

## 💾 Storage Tables

### TurretOwner
Stores the owner mapping:
```solidity
{
  smartTurretId: uint256,
  ownerCharacterId: uint256
}
```
Key: `smartTurretId`

### OwnerShotOnce
Tracks if owner has been shot this visit:
```solidity
{
  smartTurretId: uint256,
  hasBeenShot: bool
}
```
Key: `smartTurretId`

## ⚡ Gas Optimizations

- **Binary search insertion**: ~40-60% gas savings vs full sort
- **Insertion sort**: Efficient for nearly-sorted queues
- **Skip sorting on removal**: Maintains order during copy (~82% savings)
- **Minimal storage operations**: Only update what changed

## 🛠️ Development

### Prerequisites
- Node.js & pnpm
- Foundry (forge, cast)
- EVE Vault or MetaMask wallet

### Local Setup
```bash
# Clone the repo
git clone https://github.com/mbargh87/owner-only-turret.git
cd owner-only-turret

# Install dependencies
cd packages/contracts
pnpm install

# Copy env template
cp .envsample .env

# Configure for Pyrope testnet
pnpm env-stillness
```

### Deploy to Pyrope
```bash
cd packages/contracts
pnpm deploy:pyrope
```

### Manual Configuration (if needed)
```bash
# Check current owner
TURRET_ID=<your-turret-id> forge script script/CheckOwner.s.sol \
  --fork-url $RPC_URL --sig "run(address)" $WORLD_ADDRESS

# Configure turret (if DApp didn't do it)
TURRET_ID=<your-turret-id> forge script script/ConfigureTurret.s.sol \
  --fork-url $RPC_URL --broadcast --sig "run(address)" $WORLD_ADDRESS
```

## 📄 Contract Files

- `src/systems/OwnerOnlyTurretSystem.sol` - Main targeting logic
- `src/systems/Utils.sol` - Helper functions for system ID
- `src/systems/constants.sol` - Namespace and system name
- `mud.config.ts` - MUD table definitions
- `script/ConfigureTurret.s.sol` - Configuration script
- `script/CheckOwner.s.sol` - Verification script

## 🎮 Testing In-Game

1. **First Approach**: Turret shoots you once
2. **Stay in range**: Turret ignores you
3. **Leave and return**: Turret shoots you once again
4. **Bring a friend**: They get shot continuously!

## 🐛 Troubleshooting

**Turret not shooting me at all?**
- Make sure you ran registration through the DApp (v3.1+)
- Check that both transactions confirmed
- Verify with `CheckOwner.s.sol` script

**Turret shooting me continuously?**
- The turret might not be configured yet
- Run the `ConfigureTurret.s.sol` script manually
- Check System ID matches: `0x73796f776e65727475727265740000004f776e65724f6e6c7954757272657453`

**DApp won't connect?**
- Make sure you're on Pyrope network (Chain ID: 695569)
- Try EVE Vault instead of MetaMask
- Clear browser cache with `?v=31` URL parameter

## 📚 Resources

- [EVE Frontier Docs](https://docs.evefrontier.com/)
- [MUD Documentation](https://mud.dev/)
- [Builder Examples](https://github.com/projectawakening/builder-examples)

## 📝 License

MIT

## 🙏 Acknowledgments

Built using:
- [MUD Framework](https://mud.dev/) by Lattice
- [EVE Frontier World](https://evefrontier.com/) by CCP Games
- Smart Turret examples from projectawakening/builder-examples
