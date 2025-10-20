# 🎮 Owner-Only Turret - Quick Reference

## 📦 Deployment Info
```
Local Docker:  0xEdf8089F67Ce8dC619e5BA95Ad00f27be755d996
Pyrope World:  0xcdb380e0cd3949caf70c45c67079f2e27a77fc47
Your Address:  0x24ab469C82F857a2d3C7b4997840EaEC4FCBE998
```

## 🚀 Quick Commands

### Set Turret Owner
```bash
cast send 0xEdf8089F67Ce8dC619e5BA95Ad00f27be755d996 \
  "ownerturret__setTurretOwner(uint256,uint256)" \
  TURRET_ID OWNER_CHAR_ID \
  --rpc-url http://127.0.0.1:8546 \
  --private-key $PRIVATE_KEY
```

### Check Balance
```bash
cast balance 0x24ab469C82F857a2d3C7b4997840EaEC4FCBE998 --rpc-url http://127.0.0.1:8546
```

### Fund Account (if needed)
```bash
cast send 0x24ab469C82F857a2d3C7b4997840EaEC4FCBE998 --value "10ether" \
  --rpc-url http://127.0.0.1:8546 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## 🐳 Docker Commands

### Status
```bash
sg docker -c "cd ~/development/owner-only-turret/builder-examples && docker-compose ps"
```

### Logs
```bash
sg docker -c "cd ~/development/owner-only-turret/builder-examples && docker-compose logs -f world-deployer"
```

### Restart
```bash
sg docker -c "cd ~/development/owner-only-turret/builder-examples && docker-compose restart"
```

### Stop
```bash
sg docker -c "cd ~/development/owner-only-turret/builder-examples && docker-compose down"
```

## 📝 Test Scripts

### Run Tests
```bash
cd ~/development/owner-only-turret/packages/contracts
./test-deployment.sh
```

### Run Demo
```bash
cd ~/development/owner-only-turret/packages/contracts
./demo-test.sh
```

## 🌐 Deploy to Pyrope

### 1. Update .env
```properties
WORLD_ADDRESS=0xcdb380e0cd3949caf70c45c67079f2e27a77fc47
RPC_URL=<PYROPE_RPC_URL>
PRIVATE_KEY=0x13b345221484e825b9a03de67d3574f7c765d8039d93415fedf915972c1575c5
```

### 2. Deploy
```bash
cd ~/development/owner-only-turret
pnpm mud deploy --rpc <PYROPE_RPC_URL>
```

## ⚡ How It Works

```
Player → inProximity() → Is Owner?
                            ↓
                    ┌───────┴───────┐
                 YES│              │NO
                    ↓               ↓
            Priority = 0    Priority = 100
                    │               │
                (SAFE)          (TARGET)
```

## 📊 Gas Costs
- Setup: ~80,000 gas (one-time)
- Per check: ~2,100 gas (70% savings!)

## 🔗 Useful Links
- Docs: https://docs.evefrontier.com/
- Explorer: https://explorer.pyropechain.com/
- Discord: https://discord.gg/evefrontier
