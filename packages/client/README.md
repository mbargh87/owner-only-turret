# Owner-Only Turret DApp

A simple web interface for the Owner-Only Turret smart contract deployed to EVE Frontier's Pyrope Testnet.

## What This DApp Does

This DApp provides:
- ✅ Contract information and status
- ✅ **Interactive wallet connection (EVE Vault)**
- ✅ **Owner registration directly from the browser**
- ✅ Configuration instructions
- ✅ How-to guide for using the turret
- ✅ Technical details

## Quick Hosting Options

### Option 1: GitHub Pages (Free, 2 minutes)

1. Create a new GitHub repository (can be private)
2. Upload `index.html` to the repository
3. Go to Settings → Pages
4. Select "Deploy from branch" → main → / (root)
5. Click Save
6. Your DApp URL will be: `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`

### Option 2: Vercel (Free, 1 minute)

1. Install Vercel CLI: `npm install -g vercel`
2. From this directory, run: `vercel`
3. Follow the prompts
4. Your DApp URL will be provided instantly

### Option 3: Netlify Drop (Easiest, 30 seconds)

1. Go to: https://app.netlify.com/drop
2. Drag and drop the `index.html` file
3. Get your instant DApp URL

### Option 4: Local Development

For testing locally:
```bash
# Option A: Python
python3 -m http.server 8000

# Option B: Node.js
npx serve .
```

Then open: `http://localhost:8000`

## Using the DApp in EVE Frontier

Once hosted:

1. **Copy your DApp URL**
2. **In-game**, navigate to your Smart Turret
3. Click **"Configure"**
4. Click **"Edit unit"**
5. Paste your DApp URL in the **"DApp URL"** field
6. Add a name like "Owner-Only Turret"
7. Add a description
8. Click **"Save"**

Players can now view your custom DApp when they interact with your turret!

## What's Next?

This DApp now includes **full Web3 integration**! Users can:
- ✅ Connect their EVE Vault wallet
- ✅ Register as turret owner with a button click
- ✅ All transactions happen on-chain

Future enhancements could include:
- Real-time turret status
- Target history display
- Owner verification display

## Files

- `index.html` - The complete DApp (single-file, no dependencies)

## Contract Information

- **World Address:** `0x7b71fe480ac4E7E96d150A1454411c5CBFb2B1F1`
- **Namespace:** `ownerturret`
- **Network:** Pyrope Testnet (Chain ID: 695569)
- **Block:** 9699122
