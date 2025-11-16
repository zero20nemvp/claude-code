Generate a customized client landing page from the QJump template.

This command creates a complete, self-contained HTML landing page for QJump queue integration. The page includes:
- Full-screen hero section with background image
- Rewards/benefits section explaining position tiers
- Instructions section for how to join and participate
- Pre-integrated QJump widgets (Join, Leaderboard, Status)
- Tailwind CSS styling via CDN
- QJump brand colors

You will be asked to provide:
1. **Brand/Client Name** - Name of the client/campaign
2. **Queue Slug** - QJump queue identifier (e.g., "shm-main-queue")
3. **Hero Headline** - Main attention-grabbing headline
4. **Hero Subheadline** - Supporting text below headline
5. **Hero Image URL** - Background image for hero section
6. **CTA Button Text** - Call-to-action button text (e.g., "Join the Queue")
7. **Rewards Section**:
   - Title and subtitle
   - Three reward tiers with positions and benefits
8. **Instructions Section**:
   - Title and subtitle  
   - Three steps explaining how it works
9. **Brand Colors** (optional) - Primary and secondary colors (defaults to QJump blue/orange)

The command will generate a complete HTML file ready to be hosted anywhere - no build step required.
