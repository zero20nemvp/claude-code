# QJump - Invisible Queue Management for Claude Code

Generate production-ready landing pages for QJump queue widget clients in seconds.

## What is QJump?

QJump is a queue management system plugin for Claude Code that helps you rapidly build branded landing pages with integrated queue widgets. Perfect for onboarding new clients who want a complete, branded queue experience without building from scratch.

**Key Features:**
- Full-screen hero section with background image
- Rewards/benefits section explaining position-based incentives
- Instructions section for queue participation
- Pre-integrated QJump widgets (Join, Leaderboard, Status)
- Tailwind CSS styling via CDN
- Fully responsive, self-contained HTML (no build step required)

## Quick Start

### 1. Installation

Install QJump as a Claude Code plugin:

```bash
# Add the Zero2One marketplace
/plugin marketplace add http://git.laki.zero2one.ee/claude/turg.git

# Install QJump plugin
/plugin install qjump@zero2one-turg
```

### 2. Generate Your First Landing Page

Run the command and answer the prompts:

```bash
/generate-landing
```

The AI will guide you through customizing:
- **Brand/Client Name**: Name of the client/campaign
- **Queue Slug**: QJump queue identifier (e.g., "shm-main-queue")
- **Hero Section**: Headline, subheadline, background image, CTA button text
- **Rewards Section**: Three reward tiers with positions and benefits
- **Instructions Section**: Three steps explaining how it works
- **Brand Colors** (optional): Defaults to QJump blue/orange

### 3. Deploy and Use

The command generates a complete `landing-page.html` file ready to deploy anywhere:

```bash
# Deploy to any static host:
# - Netlify, Vercel, S3, etc.
# - No build step required
# - No dependencies to install
```

## Core Commands

```bash
/generate-landing    # Create a new branded landing page
```

## Example Session

```bash
$ /generate-landing

Brand Name: Sneaker Heaven
Queue Slug: sneaker-heaven-main

Hero Headline: Join the Exclusive Sneaker Drop
Hero Subheadline: Limited edition releases. First in line gets first pick.
Hero Image URL: https://images.unsplash.com/photo-sneakers.jpg
CTA Button: Secure Your Spot

Rewards Title: What You Get
Rewards Subtitle: Position matters. Here's what early joiners receive.

Tier 1 Title: First 100
Tier 1 Benefit 1: 30% off all releases
Tier 1 Benefit 2: Exclusive colorways access

# ... (continues)

✓ Generated landing-page.html
✓ Complete, self-contained HTML
✓ QJump widgets pre-integrated
✓ Ready to deploy

Deploy to any static host - no build step required.
```

## How QJump Works

### Generated Page Structure

**Section 1: Hero (Full Screen)**
- Eye-catching headline
- Supporting subheadline
- Call-to-action button that opens the Join Widget
- Background image with overlay
- Smooth scroll indicator

**Section 2: Rewards**
- Explanation of position-based benefits
- Three reward tiers (gold, silver, bronze)
- Live leaderboard widget showing current positions
- Visual hierarchy with QJump brand colors

**Section 3: Instructions**
- Clear 3-step process explanation
- Client-branded (doesn't mention "QJump")
- Status widget for checking position
- Instructions tailored to queue mechanics

### Widget Integration

The generated page includes three QJump widgets automatically:

**1. Join Widget**
- Modal popup for joining the queue
- Email collection and validation
- Referral system integration

**2. Leaderboard Widget**
- Real-time position rankings
- Shows top positions and user's position
- Updates automatically

**3. Status Widget**
- Check current position by email
- Shows queue statistics
- Position-specific benefits display

## Advanced Features

### Customization

**Colors**
- Default: QJump Blue (`#2E5C8A`) and Orange (`#F5A042`)
- Override with client brand colors during generation

**Styling**
- Tailwind CSS via CDN
- Fully responsive, mobile-first design
- No external CSS files needed

**Content**
- Hero messaging fully customizable
- 3 reward tiers with position-based benefits
- 3-step instruction flow
- Button text and colors

### Deployment

The generated HTML file is completely self-contained:

- Deploy to any static host (Netlify, Vercel, S3, etc.)
- No build step required
- No dependencies to install
- Works with any web server

## File Structure

```
qjump/
├── README.md              # This file
├── .claude-plugin/
│   └── plugin.json        # Plugin configuration
├── commands/
│   └── generate-landing.md   # Landing page generator command
├── templates/
│   └── landing.html       # Landing page template
├── examples/
│   └── sneaker-heaven-landing.html  # Sample output
├── agents/                # Future: AI agent definitions
└── hooks/                 # Future: Event hooks
```

## Requirements

- Active QJump queue (queue slug required)
- Background image hosted online (HTTPS recommended)
- Modern browser support (ES6+)
- Claude Code environment

## Tips for Success

1. **Use High-Quality Images**: WebP format recommended for performance
2. **Verify Queue First**: Ensure the queue exists before generating page
3. **Test on Mobile**: Always verify mobile responsiveness
4. **Keep Headlines Concise**: Benefit-focused messaging works best
5. **Deploy to HTTPS**: Widgets require secure context

## Troubleshooting

### Floating Join Button Not Showing

**Symptom:** The purple floating button doesn't appear in the bottom-right corner.

**Cause:** The page must be served via HTTP/HTTPS, not opened as a local file (`file://`).

**Solution:**

**Option 1: Use QJump Dev Server (Recommended)**
```bash
# Copy example to public directory
cp marketplace/qjump/examples/sneaker-heaven-landing.html public/test-landing.html

# Visit in browser (dev server should be running on port 9001)
open http://localhost:9001/test-landing.html
```

**Option 2: Use Python HTTP Server**
```bash
cd marketplace/qjump/examples
python3 -m http.server 8000
# Then visit http://localhost:8000/sneaker-heaven-landing.html
```

**What happens when it works:**
- Purple floating button appears in bottom-right corner
- Button has "Join Queue" text
- Clicking opens the join modal
- Inline CTA buttons also work (same modal)

### Widgets Don't Load
- Verify queue slug is correct
- Check browser console for errors (F12 → Console tab)
- Ensure scripts load from https://www.qjump.ee
- Confirm you're serving via HTTP (not file://)

### CORS Errors from Localhost (Expected Behavior)

**Symptom:** Browser console shows CORS errors like:
```
Access to fetch at 'https://www.qjump.ee/api/...' from origin 'http://localhost:9001'
has been blocked by CORS policy
```

**This is CORRECT and expected behavior:**
- Production QJump widgets are configured to only work on deployed client domains
- Localhost access is blocked for security reasons
- This prevents unauthorized testing against production APIs

**What this means:**
- ✅ The template HTML is production-ready as-is
- ✅ Widgets will work perfectly when deployed to client's domain
- ✅ No changes needed to fix CORS errors during local testing

**To test widgets during development:**
- Use QJump's demo queue with simulated data
- Deploy to a test domain (Netlify, Vercel preview, etc.)
- Contact QJump support to whitelist your development domain

### Leaderboard or Status Widget Empty
- Queue must have existing positions to display
- Check queue slug matches an active queue
- Verify queue is in "OPEN" or "TRADING" state

### Styling Issues
- Tailwind CDN must be accessible (check internet connection)
- Check browser supports modern CSS (Chrome 90+, Safari 14+, Firefox 88+)
- Clear browser cache and reload

### Image Not Showing
- Verify image URL is accessible (test URL in new tab)
- Use HTTPS URLs (not HTTP)
- Check CORS headers if loading from external domain
- Try a different image URL (like Unsplash) to test

## Support

For issues and questions:
- **Documentation**: https://qjump.ee/docs
- **Support Email**: support@qjump.ee
- **Issues**: https://git.laki.zero2one.ee/qjump/widget/issues

---

Welcome to QJump. Let's build invisible queue experiences. 🚀
