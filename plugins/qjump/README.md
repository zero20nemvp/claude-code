# QJump Client Landing Page Generator

Generate production-ready landing pages for QJump queue widget clients in seconds.

## Overview

This plugin creates self-contained HTML landing pages for QJump widget integration. Perfect for onboarding new clients who want a complete, branded queue experience without building from scratch.

**What you get:**
- Full-screen hero section with background image
- Rewards/benefits section explaining position-based incentives
- Instructions section for queue participation
- Pre-integrated QJump widgets (Join, Leaderboard, Status)
- Tailwind CSS styling via CDN
- Fully responsive, self-contained HTML (no build step required)

## Installation

### Option 1: Install from Marketplace (Recommended)
```bash
claude-code plugin install qjump
```

### Option 2: Install from Local Directory
```bash
# From the widget project root
claude-code plugin install ./marketplace/qjump
```

## Quick Start

### Generate a Landing Page

Run the command and answer the prompts:

```bash
/qjump:generate-landing
```

You'll be asked for:
1. **Brand/Client Name** (e.g., "Sneaker Heaven")
2. **Queue Slug** (e.g., "sneaker-heaven-main")
3. **Hero Section**:
   - Headline (e.g., "Join the Exclusive Sneaker Drop")
   - Subheadline (e.g., "Limited edition releases. First in line gets first pick.")
   - Background image URL
   - CTA button text (e.g., "Join the Queue")
4. **Rewards Section**:
   - Title and subtitle
   - Three reward tiers with positions and benefits
5. **Instructions Section**:
   - Title and subtitle
   - Three steps explaining how it works
6. **Brand Colors** (optional, defaults to QJump colors)

### Example Usage

```bash
/qjump:generate-landing

# Prompts and example answers:
Brand Name: Sneaker Heaven
Queue Slug: sneaker-heaven-main

Hero Headline: Join the Exclusive Sneaker Drop
Hero Subheadline: Limited edition releases. First in line gets first pick.
Hero Image URL: https://images.unsplash.com/photo-sneakers.jpg
CTA Button: Secure Your Spot

Rewards Title: What You Get
Rewards Subtitle: Position matters. Here's what early joiners receive.

Tier 1 Title: First 100
Tier 1 Positions: Positions 1-100
Tier 1 Benefit 1: 30% off all releases
Tier 1 Benefit 2: Exclusive colorways access
Tier 1 Benefit 3: Free express shipping

# ... (continues for all tiers and instructions)
```

### Output

The command generates a complete `landing-page.html` file ready to deploy anywhere:

```html
<!DOCTYPE html>
<html>
  <!-- Complete, self-contained landing page -->
  <!-- Tailwind CSS via CDN -->
  <!-- QJump widgets pre-integrated -->
  <!-- Fully responsive design -->
</html>
```

## Generated Page Structure

### Section 1: Hero (Full Screen)
- Eye-catching headline
- Supporting subheadline
- Call-to-action button that opens the Join Widget
- Background image with overlay
- Smooth scroll indicator

### Section 2: Rewards
- Explanation of position-based benefits
- Three reward tiers (gold, silver, bronze)
- Live leaderboard widget showing current positions
- Visual hierarchy with QJump brand colors

### Section 3: Instructions
- Clear 3-step process explanation
- Client-branded (doesn't mention "QJump")
- Status widget for checking position
- Instructions tailored to queue mechanics

## Widget Integration

The generated page includes three QJump widgets automatically:

### 1. Join Widget
```html
<script src="https://www.qjump.ee/widget/qjump-join-widget.js"
        data-queue="YOUR_QUEUE_SLUG"></script>
```
- Modal popup for joining the queue
- Email collection and validation
- Referral system integration

### 2. Leaderboard Widget
```html
<script src="https://www.qjump.ee/widget/qjump-leaderboard-widget.js"
        data-queue="YOUR_QUEUE_SLUG"></script>
```
- Real-time position rankings
- Shows top positions and user's position
- Updates automatically

### 3. Status Widget
```html
<script src="https://www.qjump.ee/widget/qjump-status-widget.js"
        data-queue="YOUR_QUEUE_SLUG"></script>
```
- Check current position by email
- Shows queue statistics
- Position-specific benefits display

## Customization

### Colors

The template uses QJump brand colors by default:
- **QJump Blue**: `#2E5C8A` (trust, reliability)
- **QJump Orange**: `#F5A042` (energy, action)

You can override with client brand colors during generation.

### Styling

The page uses Tailwind CSS via CDN. All styling is inline - no external CSS files needed. Fully responsive with mobile-first design.

### Content

All content is customizable through the generation prompts:
- Hero messaging
- Reward structure (3 tiers)
- Instruction steps (3 steps)
- Button text and colors

## Deployment

The generated HTML file is completely self-contained:

```bash
# Deploy anywhere:
- Upload to web host (Netlify, Vercel, S3, etc.)
- Serve from CDN
- Add to existing website
- No build step required
- No dependencies to install
```

## Example Output

See `examples/sneaker-heaven-landing.html` for a complete example with sample content.

## Technical Stack

- **HTML5**: Semantic, accessible markup
- **Tailwind CSS**: Via CDN (v3.x)
- **JavaScript**: Vanilla JS for widget integration
- **QJump Widgets**: Loaded from https://www.qjump.ee
- **Responsive**: Mobile-first design

## Requirements

- Active QJump queue (queue slug required)
- Background image hosted online (HTTPS recommended)
- Modern browser support (ES6+)

## Best Practices

1. **Images**: Use high-quality, optimized images (WebP recommended)
2. **Queue Slug**: Ensure the queue exists before generating page
3. **Testing**: Test the generated page with your actual queue
4. **Mobile**: Always verify mobile responsiveness
5. **Content**: Keep headlines concise and benefit-focused

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
- Documentation: https://qjump.ee/docs
- Support: support@qjump.ee
- Issues: https://git.laki.zero2one.ee/qjump/widget/issues
