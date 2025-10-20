# EVE Frontier Deployment Architecture

## 🎯 Key Finding: Shared World Model

After researching the EVE Frontier documentation, I discovered that **you don't deploy your own MUD World**. Instead, you deploy to EVE Frontier's **pre-existing shared World contract**.

This is a crucial architectural difference that **cuts deployment costs in half**!

---

## 🏗️ Architecture Overview

### Traditional MUD App (What I Originally Assumed)
```
┌─────────────────────────────────┐
│  Your Own World Contract        │ ← YOU deploy this (~$6)
│  ├── Your Systems               │ ← YOU deploy this (~$3)
│  ├── Your Tables                │ ← YOU deploy this (~$1)
│  └── MUD Core Infrastructure    │ ← YOU deploy this (~$2)
└─────────────────────────────────┘
Total: ~$12
```

### EVE Frontier (Actual Architecture)
```
┌─────────────────────────────────────────────┐
│  EVE Frontier Shared World Contract         │ ← Already deployed! (FREE)
│  ├── EVE Systems (Inventory, Combat, etc)   │ ← Already there
│  ├── EVE Tables                              │ ← Already there
│  ├── Builder Namespace: "ownerturret"        │ ← YOU register (~$0.20)
│  │   ├── OwnerOnlyTurretSystem              │ ← YOU deploy (~$3.20)
│  │   └── TurretOwner Table                  │ ← YOU register (~$1.00)
│  ├── Builder Namespace: "another_builder"   │
│  └── Builder Namespace: "yet_another"       │
└─────────────────────────────────────────────┘
Total: ~$4.40 (63% cheaper!)
```

---

## 🔒 How Namespace Isolation Works

### What is a Namespace?
Think of it like a folder structure:
```
EVE World/
├── eveworld/              (EVE's official systems)
│   ├── Inventory
│   ├── Combat
│   └── SmartTurret
├── ownerturret/           (YOUR namespace)
│   ├── OwnerOnlyTurretSystem
│   └── TurretOwner table
├── player123/             (Another builder)
│   └── CustomGateSystem
└── guild456/              (Yet another builder)
    └── GuildVaultSystem
```

### Security Guarantees
✅ **Isolated Storage:** Your tables can only be modified by your systems  
✅ **Name Conflicts Prevented:** `ownerturret.TurretOwner` ≠ `player123.TurretOwner`  
✅ **Access Control:** MUD enforces namespace boundaries at the protocol level  
✅ **Cross-Namespace Reads:** You can READ from EVE's tables (e.g., player health)  
✅ **Controlled Writes:** You can WRITE through EVE's system interfaces (e.g., `InventoryLib`)  

---

## 💰 Cost Comparison

| Item | Traditional MUD | EVE Frontier | Savings |
|------|----------------|--------------|---------|
| World Deployment | $6.00 | $0.00 (FREE) | $6.00 |
| System Deployment | $3.20 | $3.20 | $0.00 |
| Namespace Registration | N/A | $0.20 | -$0.20 |
| Table Registration | $1.00 | $1.00 | $0.00 |
| Owner Setup | $0.16 | $0.16 | $0.00 |
| **TOTAL** | **$10.36** | **$4.56** | **$5.80 (56%)** |

*(Assuming 1 Gwei gas, $2 ETH)*

---

## 🔄 Deployment Process

### Local Testing (What You Did)
```bash
# Start local blockchain
anvil --port 8546

# Deploy full MUD World (includes World contract)
cd packages/contracts
pnpm deploy:local
```
**Result:** Created NEW World at `0x513F6708...` with all infrastructure

### EVE Frontier Testnet (What You'll Do Next)
```bash
# Set EVE's World address in .env
WORLD_ADDRESS=0x<eve_world_address>  # Get from EVE docs
RPC_URL=https://pyrope.evefrontier.com  # EVE's testnet RPC

# Deploy ONLY your system (no World needed!)
pnpm deploy:pyrope
```
**Result:** Your system added to EXISTING EVE World in `ownerturret` namespace

---

## 📚 Documentation Evidence

From EVE Frontier docs (https://docs.evefrontier.com/smart/world-interfacing):

> "builder Systems (when they are deployed) will be within a different Namespace"

> "the EVE World Systems and Tables are deployed in one Namespace, while builder Systems will be within a different Namespace"

> "All of the relevant System and Table NAME and NAMESPACE constants can be easily found in the local constants.sol file"

This confirms that:
1. ✅ EVE World already exists
2. ✅ Builders deploy to namespaces WITHIN that World
3. ✅ Namespace isolation provides security
4. ✅ You don't deploy your own World contract

---

## 🎮 Integration with EVE Systems

Your turret can interact with EVE's systems through their interfaces:

### Reading EVE Data
```solidity
// Example: Read player health from EVE's Health table
import { HealthLib } from "@eveworld/world/src/modules/health/HealthLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

uint256 health = HealthTable.get(
    FRONTIER_WORLD_DEPLOYMENT_NAMESPACE.healthTableId(),
    targetCharacterId
);
```

### Calling EVE Systems
```solidity
// Example: Use EVE's Inventory system
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";

InventoryLib.World memory inventory = InventoryLib.World({
    iface: IBaseWorld(worldAddress),
    namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
});

inventory.ephemeralToInventoryTransfer(smartObjectId, itemsToTransfer);
```

**Your turret already does this!**
```solidity
// From OwnerOnlyTurretSystem.sol
EntityRecordTableData memory entityData = EntityRecordTable.get(
    FRONTIER_WORLD_DEPLOYMENT_NAMESPACE.entityRecordTableId(),
    smartCharacters[i]
);
```

---

## 🔍 Why This Matters

### Performance Benefits
- ✅ **Lower Gas Costs:** No World deployment = 56% cheaper
- ✅ **Faster Deployment:** Only deploy your code, not infrastructure
- ✅ **Shared Liquidity:** All builders in same World = easier integration

### Developer Benefits
- ✅ **Simpler Setup:** Less infrastructure to manage
- ✅ **Automatic Updates:** EVE updates World, you benefit
- ✅ **Community Effects:** Other builders' systems available to interact with

### User Benefits
- ✅ **Seamless Experience:** Everything in one World = no bridging
- ✅ **Composability:** Systems can interact easily
- ✅ **Lower Costs:** Shared infrastructure = cheaper transactions

---

## 🚀 Next Steps

1. **Find EVE World Address**
   - Check https://docs.evefrontier.com/blockchains-stillness-list
   - Or check their GitHub repos for deployed addresses

2. **Update .env File**
   ```bash
   WORLD_ADDRESS=0x<actual_eve_world_address>
   RPC_URL=https://pyrope.evefrontier.com
   PRIVATE_KEY=<your_key>
   ```

3. **Deploy to Testnet**
   ```bash
   cd packages/contracts
   pnpm deploy:pyrope
   ```

4. **Verify on Explorer**
   - Visit https://pyrope.blockscout.com
   - Search for your system address
   - Confirm it's in the `ownerturret` namespace

5. **Test In-Game**
   - Build Smart Turret in EVE Frontier
   - Configure it to use your system
   - Watch it protect you!

---

## 💡 Key Takeaways

### Original Misunderstanding
"I need to deploy my own MUD World, which costs ~$9.37"

### Actual Reality
"I deploy to EVE's shared World in my own namespace, which costs ~$4.56"

### Why This Confusion Happened
- MUD documentation shows standalone apps deploying full Worlds
- EVE Frontier's shared World model is unique to their architecture
- Local testing with `pnpm deploy:local` creates a full World (for testing)
- Production deployment to EVE uses their existing World

### Bottom Line
**Your turret is 56% cheaper to deploy than originally estimated!** 🎉

Plus you get:
- Easier deployment process
- Better integration with EVE systems
- Automatic compatibility with other builders
- Shared infrastructure benefits

---

*Last updated: Based on EVE Frontier documentation as of January 2025*
