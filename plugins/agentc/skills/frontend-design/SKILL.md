---
name: frontend-design
description: Auto-activates for frontend tasks (React, Vue, HTML/CSS, components, UI). Creates distinctive, production-grade interfaces avoiding generic AI aesthetics. Use bold design choices, distinctive typography, and high-impact animations.
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

This skill creates distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Every frontend task produces visually striking, memorable, and cohesive output.

## Detection Triggers

This skill activates automatically when the task involves:
- React/Vue/Svelte components
- HTML/CSS pages or layouts
- UI elements (buttons, forms, cards, modals)
- Landing pages or marketing sites
- Dashboards or admin panels
- Styling, theming, or design systems
- Animation or motion design

## Design Thinking (Before Coding)

**STOP before writing any frontend code.** Commit to a BOLD aesthetic direction:

### 1. Purpose
- What problem does this interface solve?
- Who uses it? What's their context?

### 2. Tone (Pick ONE and commit)

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
| Industrial/utilitarian | Function-first, tool-like |

**Choose one. Execute with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.**

### 3. Differentiation
What's the ONE thing someone will remember about this interface?

## Aesthetic Guidelines

### Typography

**DO:**
- Choose distinctive, characterful fonts
- Pair a display font with a refined body font
- Use unexpected type choices that elevate the design

**NEVER USE:**
- Inter, Roboto, Arial, system fonts
- Generic sans-serif defaults
- Same font everywhere

```css
/* GOOD */
font-family: 'Playfair Display', serif;  /* Headlines */
font-family: 'Source Sans Pro', sans-serif;  /* Body */

/* BAD - Generic AI aesthetic */
font-family: Inter, system-ui, sans-serif;
```

### Color & Theme

**DO:**
- Commit to a cohesive palette
- Use CSS variables for consistency
- Dominant color with sharp accents
- Consider dark/light theme from the start

**NEVER USE:**
- Purple gradients on white (the "AI look")
- Timid, evenly-distributed palettes
- Random color choices

```css
/* GOOD - Committed palette */
:root {
  --color-ink: #1a1a2e;
  --color-paper: #f5f0e8;
  --color-accent: #e94560;
  --color-muted: #6b7280;
}

/* BAD - Generic */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Motion & Animation

**DO:**
- Focus on high-impact moments
- Staggered reveals on page load (animation-delay)
- Scroll-triggered animations
- Surprising hover states
- Use CSS-only when possible; Motion library for React

**Prioritize:**
- One well-orchestrated page load > scattered micro-interactions
- Purposeful motion > motion everywhere

```css
/* Staggered reveal */
.card { animation: fadeUp 0.5s ease-out forwards; opacity: 0; }
.card:nth-child(1) { animation-delay: 0.1s; }
.card:nth-child(2) { animation-delay: 0.2s; }
.card:nth-child(3) { animation-delay: 0.3s; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
```

### Spatial Composition

**DO:**
- Unexpected layouts
- Asymmetry
- Overlap elements
- Diagonal flow
- Grid-breaking elements
- Generous negative space OR controlled density

**AVOID:**
- Predictable 12-column grids everywhere
- Everything centered and symmetrical
- Cookie-cutter component patterns

### Backgrounds & Visual Details

**Create atmosphere and depth:**
- Gradient meshes
- Noise textures
- Geometric patterns
- Layered transparencies
- Dramatic shadows
- Decorative borders
- Custom cursors
- Grain overlays

```css
/* Texture overlay */
.hero::before {
  content: '';
  position: absolute;
  inset: 0;
  background: url("data:image/svg+xml,...") repeat;
  opacity: 0.03;
  pointer-events: none;
}
```

## Anti-Patterns (NEVER DO)

| Anti-Pattern | Why It's Bad |
|--------------|--------------|
| Inter/Roboto/Arial fonts | Screams "AI generated" |
| Purple gradient on white | Cliched AI aesthetic |
| Predictable card layouts | No personality |
| No animation | Feels static and cheap |
| System font stack | Lazy default |
| Same design every time | Shows no creative thinking |

## Implementation Complexity

**Match complexity to vision:**

| Vision | Implementation |
|--------|----------------|
| Maximalist | Elaborate code, extensive animations, layered effects |
| Minimalist | Restraint, precision, careful spacing, subtle details |

Elegance = executing the vision well, not adding more.

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
```

## Verification Checklist

Before `/done` on a frontend task:

- [ ] Aesthetic direction chosen and documented
- [ ] Typography is distinctive (not Inter/Roboto/Arial)
- [ ] Color palette is cohesive and intentional
- [ ] At least one memorable visual element
- [ ] Motion/animation adds polish
- [ ] No generic "AI slop" patterns
- [ ] Responsive/accessible as required
- [ ] Tests pass (if applicable)

## Example Output Format

When executing a frontend task:

```
=== Frontend Design: [Task Name] ===

Aesthetic Direction: [chosen tone]
Memorable Element: [the one thing]

Typography:
  Display: [font choice]
  Body: [font choice]

Palette:
  Primary: [color]
  Accent: [color]
  Background: [color]

Implementing...
```

## Remember

Claude is capable of extraordinary creative work. Don't hold back. Show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

**No two designs should look the same.** Vary themes, fonts, aesthetics. NEVER converge on common choices across generations.
