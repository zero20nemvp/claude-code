---
name: ilx
description: ILX (Intent-Level Exchange) - Compressed semantic notation for machine-to-machine communication between language models. Represents application structure, behavior, and constraints in minimal tokens (300-500:1 compression) while preserving complete semantic information. Use for (1) dense code representation in conversations, (2) cross-language transpilation, (3) semantic analysis, (4) maintaining design intent alongside implementation.
triggers:
  - ruby-transpilation
  - semantic-analysis
  - dense-code-representation
  - intent-documentation
---

# ILX: Intent-Level Exchange

**ILX Specification v0.1** - Compressed semantic notation designed for machine-to-machine communication between language models.

ILX is not human-readable by design. Humans interact in natural English; a small language model compresses to ILX; a large language model consumes ILX and generates code.

## Quick Start (AgentC Integration)

### Automatic ILX Generation (ON by default)

ILX generation is **enabled by default** for Ruby/Rails projects.

**To disable** (if needed):

```bash
export DISABLE_ILX_EMITTER=1
echo 'export DISABLE_ILX_EMITTER=1' >> ~/.zshrc
source ~/.zshrc
```

### Automatic Generation (PreToolUse Hook)

ILX files are automatically generated when you:
- Create a new Ruby file (`.rb`)
- Edit an existing Ruby file
- Save changes to Ruby files

**Output location**: `.agentc/ilx/` (mirrors your project structure)

Example:
```
app/models/user.rb  →  .agentc/ilx/app/models/user.ilx
```

### Manual Batch Conversion

Convert all existing Ruby files in a project:

```bash
cd plugins/agentc/scripts
ruby ilx_batch_convert.rb /path/to/your/project
```

### Dependencies

Install required Ruby gems:

```bash
gem install prism rbs
```

---

## ILX Specification v0.1

### Design Principles

1. **Token Efficiency**: Maximize semantic content per token
2. **Unambiguous Parsing**: No inference required, deterministic interpretation
3. **Hierarchical Addressing**: Any node reachable by path
4. **Diffability**: Small intent changes produce small ILX changes
5. **Completeness**: Edge cases, constraints, and triggers are first-class

### Compression Target

| Codebase Size | Raw Tokens | ILX Tokens | Ratio |
|---------------|------------|------------|-------|
| 10k LOC       | ~150k      | ~500       | 300:1 |
| 100k LOC      | ~1.5M      | ~3k        | 500:1 |

---

## Grammar

### Sigils (Prefixes)

| Sigil | Meaning | Example |
|-------|---------|---------|
| `@`   | App/module root | `@app` |
| `::`  | Namespace | `::billing` |
| `#`   | Feature/action | `#create` |
| `$`   | Entity (explicit) | `$User` |
| `λ`   | Trigger/callback | `λnotify` |

**Note**: Capitalized words without sigil are implicitly entities: `User` = `$User`

### Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `→`      | Produces/transforms | `#login→Session` |
| `\|`     | Constraints follow | `#bid\|amt>current` |
| `⟹`      | Consequence/then | `\|valid⟹λemail` |
| `∧`      | And | `a>0∧b<10` |
| `∨`      | Or | `admin∨owner` |
| `=`      | Equals | `status=active` |
| `≠`      | Not equal | `bidder≠seller` |
| `>`      | Greater than | `amt>min` |
| `<`      | Less than | `now<ends` |
| `≥`      | Greater or equal | `photos≥3` |
| `≤`      | Less or equal | `attempts≤5` |
| `∈`      | Member of / type | `status∈[a,b,c]` |
| `⊂`      | Belongs to | `U⊂seller` |
| `⊃`      | Has many | `U⊃Posts` |
| `⊃?`     | Has one (optional) | `U⊃?Profile` |
| `∅`      | Null/void/nothing | `→∅` |
| `Δ`      | Increment/change | `amt>cur+Δmin` |
| `?`      | Optional field | `reserve?` |
| `!`      | Required field | `email!` |
| `~`      | Approximate/fuzzy | `~match` |
| `/`      | Rate (per time) | `5/15m` |

### Structure

#### Application Root

```
@app_name
```

#### Namespaces

```
@app
  ::namespace1
  ::namespace2
```

#### Entity Definition

```
EntityName{field1!,field2?,field3∈[a,b,c],RelatedEntity⊂role}
```

**Components**:
- `field!` — required field
- `field?` — optional field
- `field∈[a,b,c]` — enum field
- `field∈[0,5]` — numeric range
- `field∈ℝ⁺` — positive real number
- `field∈T` — timestamp
- `OtherEntity⊂role` — belongs_to relationship with role name

#### Relationships (Standalone)

```
User⊃Posts:posts
User⊃?Profile:profile
Post⊂User:author
```

Format: `Entity⊃Target:relation_name` or `Entity⊂Target:relation_name`

#### Feature Definition

```
#feature_name:@actor→Result|constraints⟹consequences
```

**Components**:
- `#feature_name` — the action identifier
- `@actor` — who performs it (optional, defaults to any)
- `→Result` — what it produces
- `|constraints` — conditions that must be true
- `⟹consequences` — side effects and triggers

#### Constraints

Constraints follow `|` and are joined with `∧` (and) or `∨` (or):

```
|amt>0∧amt≤balance∧status=active
|admin∨owner
```

#### Triggers/Consequences

Consequences follow `⟹` and represent side effects:

```
⟹λnotify(seller)∧λemail(buyer)
⟹λwebhook∧λaudit
```

Conditional triggers use `?`:

```
⟹λextend?  # triggered conditionally
```

#### Edge Cases

Edge cases are nested under features:

```
#bid→Bid|amt>current
  edge:amt=current→reject:must_exceed
  edge:bidder.suspended→reject:account
  edge:ends-now<10m⟹λextend(10m)
```

Format: `edge:condition→outcome` or `edge:condition⟹trigger`

#### Implementation References

When code must be hand-written:

```
#optimize→Route.best|impl:lib/solver.rb
```

Format: `impl:path/to/file.ext`

#### File Mappings

Link features to implementation files:

```
#bid→Bid
  files:[bids_controller.rb,bid.rb,bid_placer.rb]
  tests:[bid_placer_spec.rb]
```

### Addressing

Any node is addressable by path:

| Path | Resolves To |
|------|-------------|
| `@app` | Entire application |
| `@app::billing` | Billing namespace |
| `@app::billing#subscribe` | Subscribe feature |
| `@app::billing.Subscription` | Subscription entity |
| `@app::billing#subscribe\|` | Subscribe constraints |
| `@app::billing#subscribe⟹` | Subscribe triggers |

### Time and Rate Expressions

| Expression | Meaning |
|------------|---------|
| `5/15m`    | 5 per 15 minutes |
| `100/1h`   | 100 per hour |
| `1/1d`     | 1 per day |
| `24h`      | 24 hours |
| `10m`      | 10 minutes |
| `30d`      | 30 days |

### State Machines

```
Entity.status[state1>state2>state3]
```

Or with multiple paths:

```
Entity.status[
  draft>pending>active
  pending>rejected
  active>cancelled
]
```

---

## Complete Domain Example

```
@auction

::core
  User{email!,pw!,verified?,rating∈[0,5],suspended?}

::listings
  Listing{title!,reserve?,start_bid!,ends∈T,User⊂seller}
  User⊃Listing:listings
  Listing.status[draft>active>ended>sold]

  #create:@seller→Listing|verified=1∧photos≥3⟹λindex
  #publish:@seller→Listing.active|status=draft∧valid⟹λnotify_followers

::bidding
  Bid{amt∈ℝ⁺,User⊂bidder,Listing⊂listing,ts∈T}
  Listing⊃Bid:bids
  User⊃Bid:bids

  #place:@buyer→Bid|amt>current+Δmin∧bidder≠seller∧now<ends∧!suspended⟹λnotify(seller)
    edge:ends-now<10m⟹λextend(10m)
    edge:amt<reserve→hidden_reject
    edge:bidder.suspended→reject:account_status
    edge:first_bid∧amt<start_bid→reject:below_start

  #retract:@buyer→Bid.retracted|ts-now<5m∧!only_bid⟹λnotify(seller)

::auth
  Session{User⊂user,token!,expires∈T}

  #login→Session|email∈valid∧attempts≤5/15m∧verified=1⟹λjwt(24h)
    edge:attempts>5/15m→lockout(30m)∧λemail_alert
    edge:!verified→reject:verify_first

  #logout→∅|⟹Session.del

::payments
  Charge{amt∈ℝ⁺,Bid⊂bid,stripe_id!,status∈[pending,captured,failed]}

  #capture:@system→Charge.captured|Listing.status=sold⟹λstripe.capture∧λemail_receipt
    edge:stripe.fail→Charge.failed∧λalert_admin∧λemail_buyer
    impl:lib/stripe_service.rb
```

**Token count**: ~180 tokens

**Equivalent**:
- English prose: ~2000+ tokens
- Implementation code: ~5000+ LOC

---

## Views Specification

Views represent UI structure, data bindings, interactions, and styling in compressed form.

### View Syntax

```
#namespace/view_name
  layout:element.tailwind.classes
  element.classes:binding|constraint
```

### Core Elements

| Element | Purpose | Example |
|---------|---------|---------|
| `layout` | Root container | `layout:div.max-w-4xl.mx-auto` |
| `div` | Container | `div.p-4.bg-white` |
| `text` | Text display | `text:user.name.font-bold` |
| `img` | Image | `img:listing.photo.w-full.h-48` |
| `input` | Form field | `input:amt.border.rounded` |
| `each` | Iteration | `each:Listing.active` |
| `component` | Reusable block | `component:bid_form` |
| `action` | Interaction | `action:click→#show` |
| `empty` | Fallback | `empty:div:"No items"` |
| `cond` | Conditional | `cond:@admin` |

### Tailwind Classes

Dot-chain classes directly onto elements:

```
text:listing.title.font-bold.text-lg.truncate
img:listing.photo.w-full.h-48.object-cover.rounded-lg
div.bg-white.shadow.rounded-lg.p-4.hover:shadow-lg
```

### Formatters

Use `|fmt:` for data formatting:

| Formatter | Output |
|-----------|--------|
| `fmt:currency` | $1,234.56 |
| `fmt:date` | Jan 15, 2024 |
| `fmt:relative` | 3 hours ago |
| `fmt:truncate(n)` | First n chars... |
| `fmt:number` | 1,234 |
| `fmt:percent` | 45% |

Example: `text:listing.price|fmt:currency.text-green-600`

### Constraints on Views

Constraints follow `|` and control visibility or validation:

```
component:bid_form|@buyer∧listing.active
input:amt|min:listing.current+Δ|max:balance
action:delete|@admin∨@owner
```

### Actions

Wire interactions to features:

```
action:click→#listings/show
action:submit→#bid.place
action:+→#listings/new
action:×→#listings/destroy|confirm:"Delete?"
```

**Action modifiers**:
- `|confirm:"message"` — confirmation dialog
- `|disable:condition` — conditional disable
- `|loading` — show loading state

### Nesting

Indentation defines hierarchy:

```
#listings/index
  layout:div.container.mx-auto
    div.grid.grid-cols-3.gap-4
      each:Listing.active
        div.bg-white.rounded.shadow
          img:listing.photo[0].w-full.h-48
          div.p-4
            text:listing.title.font-bold
            text:listing.price|fmt:currency
          action:click→#listings/show
```

### Complete View Example

```
::views

  #listings/index
    layout:div.max-w-6xl.mx-auto.p-6
      div.flex.justify-between.items-center.mb-6
        text:"Listings".text-2xl.font-bold
        action:+→#listings/new.bg-blue-500.text-white.px-4.py-2.rounded|@seller
      div.grid.grid-cols-3.gap-6
        each:Listing.active.order(ends:asc)
          div.bg-white.rounded-lg.shadow.overflow-hidden.hover:shadow-lg
            img:listing.photo[0].w-full.h-48.object-cover
            div.p-4
              text:listing.title.font-bold.text-lg.truncate
              div.flex.justify-between.mt-2
                text:listing.current_bid|fmt:currency.text-green-600.font-bold
                text:listing.ends|fmt:relative.text-gray-500.text-sm
            action:click→#listings/show
        empty:div.col-span-3.py-12.text-center.text-gray-400
          text:"No active listings"
          action:+→#listings/new.text-blue-500.underline.mt-2|@seller:"Create one"

  #listings/show
    layout:div.max-w-4xl.mx-auto.p-6
      img:listing.photos|carousel.rounded-lg.mb-6
      div.flex.justify-between.items-start
        div
          text:listing.title.text-3xl.font-bold
          text:listing.seller.name.text-gray-500.mt-1:"by {}"
        div.text-right
          text:listing.current_bid|fmt:currency.text-3xl.font-bold.text-green-600
          text:listing.bid_count.text-gray-500:"{} bids"
      text:listing.description.mt-6.text-gray-700.leading-relaxed
      component:bid_form.mt-8.p-6.bg-gray-50.rounded-lg|@buyer∧listing.active∧!own
        div.flex.gap-4
          input:amt.flex-1.border.rounded.px-4.py-2.text-lg|min:listing.current+Δmin|placeholder:"Your bid"
          action:submit→#bid.place.bg-blue-500.text-white.px-6.py-2.rounded.font-bold
        text:listing.min_increment|fmt:currency.text-sm.text-gray-500.mt-2:"Minimum increment: {}"
      component:bid_history.mt-8|listing.bids.any?
        text:"Bid History".font-bold.text-lg.mb-4
        div.divide-y
          each:listing.bids.recent(10)
            div.flex.justify-between.py-3
              text:bid.bidder.name.truncate
              div.text-right
                text:bid.amt|fmt:currency.font-bold
                text:bid.ts|fmt:relative.text-gray-500.text-sm
```

**Token Efficiency** (typical view):

| Representation | Tokens |
|----------------|--------|
| Full ERB/HTML | ~800 |
| ILX + Tailwind | ~120 |
| **Compression** | **~7:1** |

---

## File Structure

```
.claude/
  ilx/
    domain.ilx      # Root file, imports namespaces
    auth.ilx        # Auth namespace
    billing.ilx     # Billing namespace
    views.ilx       # UI views
    ...
```

Or single file for smaller apps:

```
.claude/
  app.ilx
```

---

## Extraction vs Authoring

### Authoring (ilx-first)

Human describes in English → SLM compresses to ILX → LLM generates code

### Extraction (code-first)

Existing code → LLM extracts to ILX → Human embellishes intent → ILX maintained by hooks

### Hybrid

Extract structure from code, author intent and edge cases manually

---

## Ruby Emitter (Current Implementation)

The current Ruby emitter (`ilx_emitter.rb`) generates a simplified AST-based ILX format:

### Node Types

| Type | Description | Example |
|------|-------------|---------|
| `L` | Literal | `LS"hello"` (String), `LI42` (Integer) |
| `F` | Function/Lambda | `FSS3` (String→String, body at node 3) |
| `A` | Apply/Call | `ASc0p` (String, concat, args: node0, param0) |
| `B` | Branch (if/else) | `BS012` (cond=0, then=1, else=2) |
| `W` | While loop | `WU01` (cond=0, body=1) |
| `R` | Array/Range | `RA012` (elements: 0,1,2) |
| `M` | Map/Hash | `MH0:1,2:3` (pairs key:value) |
| `G` | Range | `GR01` (from=0, to=1) |

### Type System

| Code | Type |
|------|------|
| `S` | String |
| `I` | Int |
| `B` | Bool |
| `U` | Unit |
| `A` | Array |
| `H` | Hash |
| `R` | Range |

### Primitives

| Code | Operation | Ruby |
|------|-----------|------|
| `c` | concat | `<<`, `concat` |
| `p` | print | `puts`, `print` |
| `+` | add | `+` |
| `-` | subtract | `-` |
| `*` | multiply | `*` |
| `/` | divide | `/` |
| `=` | equals | `==` |
| `s` | to_s | `to_s` |
| `i` | to_i | `to_i` |
| `l` | length | `length`, `size` |

### Format

```
@file:line:method;node1;node2;node3*
```

Each ILX file contains:
- Source map (`@file:line:method`)
- Semantic nodes (separated by `;`)
- End marker (`*`)

### Example: Ruby → ILX

**Input**:
```ruby
# app/models/user.rb
class User
  def greet(name)
    message = "Hello, #{name}!"
    puts message
  end
end
```

**Output**:
```
@app/models/user.rb:2:greet;LS"Hello, ";LS"p0";ASc01;ASp2*
```

**Breakdown**:
- `@app/models/user.rb:2:greet` - Source location
- `LS"Hello, "` - Node 0: String literal
- `LS"p0"` - Node 1: Parameter 0 (name)
- `ASc01` - Node 2: Apply concat to nodes 0,1
- `ASp2` - Node 3: Apply print to node 2
- `*` - End marker

### Base-36 Encoding

Node references use base-36 (0-9, a-z):
- `0` = node 0
- `9` = node 9
- `a` = node 10
- `z` = node 35
- `10` = node 36

---

## RBS Integration

The Ruby emitter automatically detects and uses RBS type signatures.

### RBS File Locations

1. **Co-located**: Same directory as `.rb` file
   ```
   app/models/user.rb
   app/models/user.rbs  ← Found here
   ```

2. **Sig directory**: Mirroring project structure
   ```
   app/models/user.rb
   sig/app/models/user.rbs  ← Or here
   ```

### Type Mapping

```ruby
# user.rbs
def greet: (String) -> String  # becomes FSS (String→String)
def count: (Integer) -> Integer # becomes FII (Integer→Integer)
def valid?: (User) -> bool      # becomes FSB (String→Bool)
```

Without RBS, types default to `String` (`S`).

---

## AgentC Integration Details

### Hook Lifecycle

1. User saves `.rb` file via Write/Edit tool
2. PreToolUse hook fires (before file write)
3. Hook receives JSON via stdin:
   ```json
   {
     "tool_name": "Write",
     "tool_input": {
       "file_path": "/path/to/file.rb",
       "content": "..."
     }
   }
   ```
4. Hook checks:
   - Is ILX disabled? (`DISABLE_ILX_EMITTER=1`)
   - Dependencies installed?
   - Is this a `.rb` file?
   - Outside `vendor/` and test fixtures?
5. If yes:
   - Find project root (Gemfile or .git)
   - Look for `.rbs` file
   - Run ILX emitter
   - Write to `.agentc/ilx/`
6. Hook exits with code 0 (always allow file operation)

### Output Directory Structure

```
your-project/
├── app/
│   ├── models/
│   │   └── user.rb
│   └── controllers/
│       └── users_controller.rb
├── sig/
│   └── app/
│       └── models/
│           └── user.rbs
└── .agentc/
    └── ilx/                    ← ILX output
        ├── app/
        │   ├── models/
        │   │   └── user.ilx    ← Generated
        │   └── controllers/
        │       └── users_controller.ilx
```

### Debug Logging

All activity logged to `/tmp/ilx-emitter-hook.log`:

```bash
tail -f /tmp/ilx-emitter-hook.log
```

### Performance

- Dependency check: 1-2ms (cached)
- Project root detection: 5-10ms
- ILX emission: 10-50ms (file-size dependent)
- File write: 1-2ms
- **Total**: 15-65ms per edit

### Batch Conversion Performance

- **Small project** (100 files): ~3-5 seconds
- **Medium project** (1000 files): ~30-60 seconds
- **Large project** (5000 files): ~2-5 minutes

---

## Error Handling

All errors are **non-blocking**. File operations always succeed regardless of ILX generation status.

### Missing Dependencies

**Error**: `LoadError: cannot load such file -- prism`

**Solution**:
```bash
gem install prism rbs
```

### Parse Errors

**Error**: Ruby syntax error in source file

**Behavior**: Hook warns, allows file write, no `.ilx` generated

### RBS Errors

**Error**: Invalid RBS syntax

**Behavior**: Emitter warns, continues without types (defaults to String)

### No Project Root

**Error**: Standalone `.rb` file outside project

**Behavior**: Hook logs "no project root", skips ILX generation

---

## Troubleshooting

### ILX Files Not Being Generated

1. Check if disabled (ILX is ON by default):
   ```bash
   echo $DISABLE_ILX_EMITTER  # Should be empty (not set) or not equal to 1
   ```

2. Check dependencies:
   ```bash
   ruby -e "require 'prism'; require 'rbs'; puts 'OK'"
   ```

3. Check debug log:
   ```bash
   tail -f /tmp/ilx-emitter-hook.log
   ```

4. Test emitter manually:
   ```bash
   cd plugins/agentc/scripts
   ruby ilx_emitter.rb /path/to/file.rb
   ```

### Hook Not Firing

1. Verify hooks.json:
   ```bash
   cat plugins/agentc/hooks/hooks.json | jq '.hooks.PreToolUse'
   ```

2. Check executable:
   ```bash
   ls -l plugins/agentc/hooks/ilx_emitter_hook.rb
   # Should show: -rwxr-xr-x
   ```

3. Test manually (ILX is ON by default, don't set DISABLE_ILX_EMITTER):
   ```bash
   echo '{"tool_name":"Write","tool_input":{"file_path":"test.rb"}}' | \
     CLAUDE_PLUGIN_ROOT=plugins/agentc \
     ruby plugins/agentc/hooks/ilx_emitter_hook.rb
   ```

---

## Gitignore

Add to `.gitignore`:

```
# ILX generated files
.agentc/
```

ILX files are generated artifacts and should not be committed.

---

## Maintenance

### Post-Commit Hook (Future)

Detects:
- New files → prompt for ILX addition
- Changed files → diff against ILX, flag drift
- Deleted files → mark ILX nodes as deprecated

ILX updates require human approval to preserve intent accuracy.

---

## Use Cases

### 1. Dense Code Context for LLM Conversations

**Problem**: Large Ruby codebases exceed LLM context windows

**Solution**: Use ILX to compress code ~95%, fitting more context

```bash
# Convert entire codebase
ruby ilx_batch_convert.rb .

# Reference .ilx files in conversations instead of .rb files
# 10,000 lines of Ruby → 500 lines of ILX
```

### 2. Cross-Language Transpilation

**Problem**: Migrating Ruby codebase to TypeScript

**Solution**: Ruby → ILX → TypeScript transpiler

```
Ruby + RBS → ILX (semantic graph)
          ↓
     TypeScript emitter (future)
          ↓
     TypeScript + types
```

### 3. Semantic Analysis

**Problem**: Analyzing code patterns across large codebase

**Solution**: Parse ILX to find semantic patterns

```bash
# Find all functions with String→String signature
grep -r "FSS" .agentc/ilx/

# Find all conditionals
grep -r "^B" .agentc/ilx/
```

### 4. Intent Documentation

**Problem**: Design intent lost in implementation details

**Solution**: Maintain parallel ILX describing intent, constraints, edge cases

---

## Future Enhancements

1. **Full ILX v0.1 emitter** - Complete spec implementation
2. **TypeScript emitter** - ILX → TypeScript transpiler
3. **JavaScript emitter** - ILX → JavaScript transpiler
4. **Parallel batch conversion** - Process files concurrently
5. **Incremental updates** - Only regenerate changed files
6. **ILX visualization** - Graph viewer for semantic structure
7. **Type inference** - Infer types without RBS

---

## Summary

ILX integration provides automatic semantic graph generation:

- **Automatic**: PreToolUse hook fires on every `.rb` file write
- **Type-aware**: Uses RBS signatures when available
- **Dense**: 95% token reduction vs JSON AST (300-500:1 for full spec)
- **Non-blocking**: Never interrupts file operations
- **Debuggable**: Full logging to `/tmp/ilx-emitter-hook.log`
- **Spec v0.1**: Complete grammar for domain, views, constraints, edge cases

ILX generation is **enabled by default**. Just start writing Ruby code and ILX files will be generated automatically in `.agentc/ilx/`. To disable, set `export DISABLE_ILX_EMITTER=1`.

---

**ILX Specification v0.1**
Draft: 2024-12-31
Status: Experimental
