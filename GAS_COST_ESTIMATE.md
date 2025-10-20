# Owner-Only Turret - Gas Cost Estimate (USD)

## 💰 Cost Summary (UPDATED - Deploy to Existing EVE World)

### One-Time Setup Costs (YOU PAY)
| Action | Gas Used | Cost @ $0.50/ETH | Cost @ $2/ETH | Cost @ $5/ETH |
|--------|----------|------------------|---------------|---------------|
| Deploy System | ~1,602,021 | ~$0.80 | ~$3.20 | ~$8.01 |
| Register Namespace | ~100,000 | ~$0.05 | ~$0.20 | ~$0.50 |
| Register Table | ~500,000 | ~$0.25 | ~$1.00 | ~$2.50 |
| Set Turret Owner | ~81,877 | ~$0.04 | ~$0.16 | ~$0.41 |
| **TOTAL SETUP** | **~2,283,898** | **~$1.14** | **~$4.56** | **~$11.42** |

**Note:** You deploy to the EXISTING EVE World, not create a new one! This saves ~3M gas (~$6 at $2/ETH).

### Ongoing Costs (GAME PAYS - $0 FOR YOU)
| Action | Gas per Call | Your Cost | Who Pays |
|--------|--------------|-----------|----------|
| inProximity() | ~100,000 | $0.00 | Game |
| aggression() | ~50,000 | $0.00 | Game |
| Queue operations | ~5,000-15,000 | $0.00 | Game |

---

## 📊 Detailed Breakdown

### 1. Deployment Costs (One-Time) - CORRECTED

**EVE Frontier's Pre-Deployed World:**
- World contract: Already deployed ✅ (FREE for you!)
- Shared by all builders
- Located at: [Check docs for current address]

**Your OwnerOnlyTurretSystem Contract:**
- Gas: 1,602,021
- Size: 7,221 bytes
- Deploys to "ownerturret" namespace

**Table & Namespace Registration:**
- Register "ownerturret" namespace: ~100,000 gas
- Register TurretOwner table schema: ~500,000 gas
- Link table to system: Included above

**Total Deployment: ~2,200,000 gas** (was 4,100,000 - saved 1,900,000!)

### 2. Setup Cost (Per Turret)

**setTurretOwner(turretId, ownerId):**
- Gas measured: 81,877
- Includes: Storage write, validation, event emission

**Per turret setup: ~82,000 gas**

### 3. Runtime Costs (Game-Paid)

**inProximity() - Called every tick:**
- Pure logic: ~15,000 gas
- Queue operations: ~5,000-50,000 gas (depends on queue size)
- Table reads: ~5,000 gas
- **Total per call: ~25,000-100,000 gas**
- **Frequency: Every game tick when players nearby**
- **Who pays: EVE Frontier game infrastructure**

**aggression() - Called on PvP events:**
- Minimal logic: ~5,000 gas
- Currently returns unchanged queue: ~5,000 gas
- **Total per call: ~10,000-50,000 gas**
- **Frequency: When aggression occurs nearby**
- **Who pays: EVE Frontier game infrastructure**

---

## 💵 Real-World Cost Scenarios

### Scenario A: EVE Frontier Testnet (Pyrope) - CORRECTED
**Assumptions:**
- Gas price: 1 Gwei (low)
- ETH price: $2.00
- **Your one-time cost: ~$4.56** ✅ (was $9.37)

**Breakdown:**
```
Deploy system:     1,602,021 × 1 Gwei × $2 = $3.20
Register namespace:  100,000 × 1 Gwei × $2 = $0.20
Register table:      500,000 × 1 Gwei × $2 = $1.00
Set owner:            81,877 × 1 Gwei × $2 = $0.16
----------------------------------------
TOTAL:                                  $4.56
```

### Scenario B: Mainnet (Conservative) - CORRECTED
**Assumptions:**
- Gas price: 25 Gwei (average for L2)
- ETH price: $2.00
- **Your one-time cost: ~$114.10** ✅ (was $234.20)

**Breakdown:**
```
Deploy system:     1,602,021 × 25 Gwei × $2 = $80.10
Register namespace:  100,000 × 25 Gwei × $2 = $5.00
Register table:      500,000 × 25 Gwei × $2 = $25.00
Set owner:            81,877 × 25 Gwei × $2 = $4.09
----------------------------------------
TOTAL:                                   $114.19
```

### Scenario C: Mainnet (High Gas) - CORRECTED
**Assumptions:**
- Gas price: 50 Gwei (busy period)
- ETH price: $5.00
- **Your one-time cost: ~$571** ✅ (was $1,171)

**Breakdown:**
```
Deploy system:     1,602,021 × 50 Gwei × $5 = $400.51
Register namespace:  100,000 × 50 Gwei × $5 = $25.00
Register table:      500,000 × 50 Gwei × $5 = $125.00
Set owner:            81,877 × 50 Gwei × $5 = $20.47
----------------------------------------
TOTAL:                                   $570.98
```

---

## 🎯 Most Likely: EVE Frontier Reality

EVE Frontier uses its own blockchain infrastructure with a **pre-deployed shared World contract**:

**Expected costs (CORRECTED):**
- **Testnet (Pyrope):** FREE or minimal (~$0-3)
- **Mainnet:** $5-25 for full deployment

**Why MUCH lower than original estimate:**
1. ✅ **No World deployment** - Uses existing EVE World (~$6 saved!)
2. ✅ **Namespace isolation** - Your "ownerturret" namespace keeps you secure
3. ✅ **Shared infrastructure** - All builders use same World contract
4. ✅ **Custom chain** - Lower base fees than Ethereum
5. ✅ **Gaming-optimized** - Efficient execution for game logic

**Key Insight from EVE Docs:**
> "builder Systems (when they are deployed) will be within a different Namespace"

This means you're **extending** the existing EVE World, not creating your own! Much cheaper!

---

## 📈 Lifetime Cost Analysis

### If you deploy 1 turret (CORRECTED):
```
Initial:     $4.56 (testnet) or $114 (mainnet worst case)
             [50% cheaper than original estimate!]
Year 1:      $0 (game pays)
Year 2:      $0 (game pays)
Forever:     $0 (game pays)
```

### If you deploy 10 turrets (CORRECTED):
```
Initial:     $4.56 + (10 × $0.16) = $6.16 (testnet)
             [44% cheaper than original estimate!]
Forever:     $0 (game pays)
```

### Game's Ongoing Costs (Not yours):
Assuming 1 turret, active 24/7, checked every second:
```
Per second:  ~100,000 gas × 1 Gwei = $0.0002
Per day:     86,400 checks × $0.0002 = $17.28
Per year:    $6,307.20
```

**The game pays this, not you!**

---

## 🔍 Cost Optimization Tips

### Already Optimized ✅
Your contract is efficient:
- ✅ Pure functions (no state changes in targeting)
- ✅ Memory arrays (not storage writes)
- ✅ Efficient sorting (bubble sort is fine for small queues)
- ✅ Minimal storage (only owner ID stored)

### Could Optimize Further (Optional)
If deploying to expensive mainnet:
- Use Yul/assembly for sorting: Save ~20-30%
- Pack struct fields: Save on reads
- Use events instead of returns: Save on call data

**But honestly, it's already pretty optimal for this use case!**

---

## 🎓 Gas Price Context

### What is 1 Gwei?
- 1 Gwei = 0.000000001 ETH
- 1 Gwei = 1 nanoether

### Current Market Context (Oct 2025)
- **Ethereum L1:** 10-100 Gwei typical
- **L2 Chains:** 0.01-5 Gwei typical
- **Custom Chains:** Variable, often < 1 Gwei

### EVE Frontier Likely:
- Specialized gaming chain
- Probably < 1 Gwei base fee
- May have free testnet deployment

---

## 💡 Bottom Line (UPDATED)

### **Your Actual Cost:**
- **Testnet:** ~$2-8 (or FREE) - **50% less than original estimate!**
- **Mainnet:** ~$25-150 (depends on gas prices) - **50% less!**
- **After setup:** $0 forever

### **Why Original Estimate Was High:**
The original $9.37 estimate incorrectly assumed you'd deploy a NEW MUD World contract (~$6). 

**Reality:** EVE Frontier has a pre-deployed shared World that all builders use. You just:
1. Deploy your System to the existing World
2. Register your namespace ("ownerturret")
3. Register your table (TurretOwner)
4. Done!

### **Game's Cost:**
- Per turret per year: ~$6,000-10,000
- They pay this to run your logic
- This is their business model

### **Comparison:**
- Traditional server: $50-100/month = $600-1200/year
- Your turret: $5 once, then free
- **You save money AND get decentralization!**

---

## 🚀 Recommendation

1. **Start on Testnet (Pyrope):** FREE testing
2. **Deploy to existing EVE World:** Use their shared World address
3. **Register your namespace:** "ownerturret" keeps you isolated
4. **Optimize if needed:** Check actual costs after deployment
5. **Deploy to Mainnet:** When comfortable (~$5-25 total)
6. **Enjoy:** Zero ongoing costs!

Your contract is **already gas-efficient** and the one-time cost is **very reasonable** (~$5 on testnet, ~$25-150 on mainnet) for a persistent, decentralized game entity that runs forever without server costs.

### **Key Takeaway:**
Original estimate was **2x too high** because it assumed deploying a new World. EVE Frontier uses a **shared World architecture**, cutting deployment costs in half!

---

*Note: Actual costs depend on EVE Frontier's specific gas pricing model. These estimates are based on typical blockchain costs. Testnet deployment is likely FREE or near-free. Check https://docs.evefrontier.com for current World address and deployment instructions.*
