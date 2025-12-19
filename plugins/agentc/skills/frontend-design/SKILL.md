---
name: frontend-design
description: Auto-activates for frontend tasks (React, Vue, HTML/CSS, components, UI). Creates distinctive, production-grade interfaces avoiding generic AI aesthetics. Calibrates design intensity to context.
triggers:
  - React components
  - Vue components
  - HTML/CSS pages
  - UI components
  - Landing pages
  - Dashboards
  - Forms and inputs
  - Styling tasks
---

# Frontend Design Skill

**Auto-activates when task involves frontend/UI work.**

Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Deliver real working code with exceptional attention to aesthetic details and creative choices—calibrated to context.

## Detection Triggers

This skill activates automatically when the task involves:
- React/Vue/Svelte components
- HTML/CSS pages or layouts
- UI elements (buttons, forms, cards, modals)
- Landing pages or marketing sites
- Dashboards or admin panels
- Styling, theming, or design schemes
- Animation or motion design

## Before You Design

### 1. Understand the Context

- **Purpose**: What problem does this solve? Who uses it?
- **Tone**: What emotion should it evoke? (trust, delight, urgency, calm, edge)
- **Constraints**: Framework, performance budget, accessibility requirements
- **References**: Any existing brand, inspiration, or direction provided?

### 2. Calibrate Intensity

Not every interface needs to be "memorable." Match expression level to context:

| Level | When | Character Lives In |
|-------|------|---------------------|
| **High** | Marketing sites, portfolios, creative brands, landing pages, launch announcements | Bold typography, dramatic layouts, rich animation, experimental elements |
| **Balanced** | Consumer apps, e-commerce, content platforms, SaaS products | One or two distinctive choices (typography + color), refined micro-interactions |
| **Restrained** | Enterprise tools, dashboards, documentation, data-heavy UIs | Perfect spacing, subtle accent color, typographic precision, zero excess |

Restrained ≠ boring. A dashboard with perfect information hierarchy, one well-chosen accent, and buttery-smooth transitions has more character than a cluttered one with gradients everywhere.

### 3. Commit to a Direction

Pick an aesthetic stance and execute with conviction:

| Direction | Character |
|-----------|-----------|
| Brutally minimal | Stark, functional, no decoration |
| Maximalist chaos | Dense, layered, overwhelming (intentionally) |
| Retro-futuristic | 80s/90s tech meets modern |
| Organic/natural | Soft curves, earthy tones, flowing |
| Luxury/refined | Premium materials feel, subtle elegance |
| Playful/toy-like | Bouncy, colorful, delightful |
| Editorial/magazine | Grid-based, typographic hierarchy |
| Brutalist/raw | Exposed structure, raw HTML energy |
| Art deco/geometric | Sharp angles, gold accents, symmetry |
| Swiss/grid-locked | Precision, mathematical, structured |
| Glassmorphic/layered | Depth through transparency and blur |
| Industrial/utilitarian | Function-first, tool-like |

**The worst outcome is uncommitted middle-ground that feels like nothing.** Bold maximalism and restrained minimalism both work—the key is intentionality.

## Design Principles

### Typography

Choose fonts with character. Pair a distinctive display font with a refined body font.

**Avoid**: Inter, Roboto, Arial, system-ui defaults, Open Sans—not because they're bad, but because they signal "no decision was made."

**Font directions by tone:**

| Tone | Pairings |
|------|----------|
| Editorial/Refined | Freight Display + Söhne, Canela + Founders Grotesk, Playfair Display + Source Sans 3 |
| Playful/Friendly | Fraunces + DM Sans, Recoleta + Nunito Sans, Lobster + Lato |
| Technical/Modern | JetBrains Mono + Space Grotesk, IBM Plex Mono + IBM Plex Sans, Fira Code + Fira Sans |
| Luxury/Minimal | Cormorant Garamond + Karla, Bodoni Moda + Work Sans, Libre Baskerville + Raleway |
| Brutalist/Raw | Monument Extended + Input Mono, Bebas Neue + Roboto Mono, Oswald + Anonymous Pro |

**Free sources**: Google Fonts, Fontshare, Font Squirrel
**Paid/experimental**: Future Fonts, Pangram Pangram, Colophon

```css
/* GOOD - Distinctive pairing */
--font-display: 'Playfair Display', serif;
--font-body: 'Source Sans 3', sans-serif;

/* BAD - Generic AI aesthetic */
font-family: Inter, system-ui, sans-serif;
```

### Color & Theme

Commit to a cohesive palette. Use CSS variables for consistency.

**Principles:**
- Dominant color + sharp accent outperforms timid, evenly-distributed palettes
- Dark themes need careful contrast hierarchy, not just inverted colors
- Consider emotional weight: saturated = energetic, muted = sophisticated, monochrome = focused

**Avoid:**
- Purple-to-blue gradients on white (the "AI startup" look)
- Random accent colors with no relationship
- Pure black (#000) on pure white (#fff) without relief

**Instead:**
- Near-black with a color cast (`#0a0a0f`, `#1a1a2e`, `#0f1419`)
- Warm whites and creams (`#faf9f7`, `#f5f5f0`)
- Unexpected accent choices (rust, chartreuse, electric cyan, terracotta)
- Monochromatic with one deliberate pop

```css
/* GOOD - Committed palette */
:root {
  --color-ink: #1a1a2e;
  --color-paper: #f5f0e8;
  --color-accent: #e94560;
  --color-muted: #6b7280;
}

/* BAD - Generic gradient */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Spatial Composition

Break predictable patterns with intention:

| Generic | Distinctive Alternative |
|---------|------------------------|
| Card grid with equal spacing | Overlapping cards, asymmetric masonry, varied card sizes |
| Centered hero + stock photo | Full-bleed typography, illustrated elements, editorial negative space |
| Symmetric two-column layout | 2/3 + 1/3 split, offset grid, diagonal flow |
| Everything contained in boxes | Elements breaking containers, bleeding to edges, overlapping sections |

**But remember**: Unexpected layouts must still have responsive behavior and logical reading order. Creativity isn't an excuse for broken UX.

### Motion & Animation

Prioritize high-impact moments over scattered micro-interactions.

**High-value animation opportunities:**
- Page load: Staggered reveals with `animation-delay` create orchestrated entrances
- Scroll-triggered: Elements animating into view as user scrolls
- Hover states: Transforms, color shifts, revealed content
- State changes: Smooth transitions between UI states

**Technical approach:**
- CSS-only for HTML (use `@keyframes`, `transition`, `animation`)
- Motion/Framer Motion for React when available
- GSAP for complex sequenced animations
- Always respect `prefers-reduced-motion`

```css
/* Staggered reveal */
.card {
  animation: fadeUp 0.5s ease-out forwards;
  opacity: 0;
}
.card:nth-child(1) { animation-delay: 0.1s; }
.card:nth-child(2) { animation-delay: 0.2s; }
.card:nth-child(3) { animation-delay: 0.3s; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Texture & Atmosphere

Solid color backgrounds are missed opportunities. Create depth:

- **Gradient meshes**: Multi-point gradients with organic color transitions
- **Noise/grain**: Subtle texture that adds warmth (SVG filter or CSS)
- **Geometric patterns**: Repeating shapes, grids, dots as background elements
- **Layered transparencies**: Overlapping semi-transparent elements
- **Dramatic shadows**: `box-shadow` stacks for elevation and depth

```css
/* Noise texture overlay */
.textured {
  position: relative;
}
.textured::after {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  opacity: 0.03;
  pointer-events: none;
}
```

## Anti-Patterns (NEVER DO)

These signal "AI-generated" or "no designer touched this":

| Category | Anti-Pattern |
|----------|--------------|
| **Typography** | Inter/Roboto/Arial as primary font, generic font stacks, inconsistent sizing scale |
| **Color** | Purple-blue gradients, random accent colors, pure black on pure white, the "Stripe purple" palette |
| **Layout** | Identical card grids, perfectly centered everything, symmetric layouts without tension |
| **Components** | Rounded-corner cards with drop shadows (the "Tailwind default" look), generic hero patterns |
| **Content** | Stock photography (especially diverse-team-at-computer), placeholder Lorem Ipsum left in, generic icons |
| **Effects** | Gratuitous blur/glassmorphism, animations on everything, parallax for no reason |

## Accessibility Is Non-Negotiable

Creative design and accessibility coexist. Every project must:

- [ ] Maintain logical DOM order regardless of visual layout
- [ ] Ensure keyboard navigation works completely
- [ ] Meet WCAG AA contrast ratios (4.5:1 body text, 3:1 large text)
- [ ] Provide focus indicators (style them creatively, but they must exist)
- [ ] Respect `prefers-reduced-motion` and `prefers-color-scheme`
- [ ] Use semantic HTML elements (`<nav>`, `<main>`, `<article>`, etc.)

If a design choice breaks accessibility, find a creative solution that preserves both. Low-contrast aesthetics can offer a high-contrast mode. Wild layouts can still have sensible tab order.

## Framework Considerations

### Vanilla HTML/CSS
Maximum creative freedom. Use modern CSS (grid, custom properties, `@layer`, `@container`). Self-contained in single file when possible.

### React
- Use Motion/Framer Motion for animation when available
- CSS Modules or styled-components for scoped styles
- Prefer CSS variables over JS-based theming when possible

### Tailwind
Tailwind's defaults are the anti-patterns this skill avoids. When using Tailwind:
- Extend the theme with custom colors, fonts, spacing
- Use arbitrary values (`text-[#1a1a2e]`) for distinctive choices
- Don't rely on default color palette or default shadows
- Consider `@apply` sparingly to create distinctive component classes

### Vue/Svelte/Others
Same principles apply. Use framework-native animation tools, scoped styles, and component patterns.

## Integration with TDD

Frontend tasks still follow TDD when applicable:

1. **Visual tests** - Snapshot tests for component rendering
2. **Interaction tests** - Click handlers, form submissions
3. **Accessibility tests** - ARIA labels, keyboard navigation

```typescript
// Example: Testing a styled button
test('renders with correct styling', () => {
  render(<Button variant="primary">Click me</Button>);
  const button = screen.getByRole('button');
  expect(button).toHaveClass('btn-primary');
});

test('triggers animation on hover', async () => {
  render(<Button>Hover me</Button>);
  await userEvent.hover(screen.getByRole('button'));
  // Assert animation state
});

test('respects reduced motion preference', () => {
  // Mock prefers-reduced-motion
  render(<Button animated>Click me</Button>);
  // Assert no animation classes applied
});
```

## Delivery Format

When executing a frontend task:

```
=== Frontend Design: [Task Name] ===

Context: [purpose + audience]
Intensity: [high | balanced | restrained]
Aesthetic Direction: [chosen tone]
Memorable Element: [the one thing]

Typography:
  Display: [font choice + why]
  Body: [font choice]

Palette:
  Primary: [color]
  Accent: [color]
  Background: [color]

Implementing...
```

## Responding to Feedback

| Feedback | Response Approach |
|----------|-------------------|
| "Too much / too busy" | Identify 1-2 elements to remove while keeping core direction. Simplify, don't flatten. |
| "Too boring / generic" | Amplify ONE element dramatically rather than adding everywhere. |
| "Different direction entirely" | Propose 2-3 alternative aesthetics with distinct moods. Explain the tradeoffs. |
| "More like [reference]" | Study the reference, extract its principles (not pixels), adapt to context. |
| "Keep the layout, change the style" | Preserve structure, swap typography + color + texture layer. |

## Verification Checklist

Before `/done` on a frontend task:

- [ ] Context assessed and intensity calibrated
- [ ] Aesthetic direction chosen and documented
- [ ] Typography is distinctive (not Inter/Roboto/Arial)
- [ ] Color palette is cohesive and intentional
- [ ] At least one memorable visual element
- [ ] Motion/animation adds polish (respects reduced-motion)
- [ ] No generic "AI slop" patterns
- [ ] Accessibility requirements met
- [ ] Responsive behavior tested
- [ ] Tests pass (if applicable)

## Remember

Claude is capable of extraordinary creative work. The goal isn't creativity for its own sake—it's making interfaces that feel *designed*, not generated. Every choice should be intentional, every detail considered.

**No two designs should look the same.** Vary themes, fonts, aesthetics. NEVER converge on common choices across generations.

**Match complexity to vision.** Maximalist designs need elaborate code with extensive animations and effects. Minimalist designs need restraint, precision, and careful attention to spacing and subtle details. Elegance comes from executing the vision well.
