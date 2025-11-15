# /add-goal - Create New Goal

**CRITICAL: This is the ONLY way to create plans when AgentH is active. No ExitPlanMode. No informal plans. All planning goes through the goal system.**

## Usage

When the user requests planning or wants to start a new project:
1. Gather requirements through questions
2. Create a structured goal with WOOP methodology
3. Add to goals.json
4. Auto-activate the goal

## Instructions

### Step 1: Gather Information

Ask the user (use AskUserQuestion tool if needed):

**Required:**
- Goal name (short, descriptive)
- Goal type: "construction" (building something) or "life" (personal goal)
- Wish: What do they want to accomplish?
- Deadline (if any)

**Optional but recommended:**
- Current state: Where are they now?
- Done when: How will they know it's complete?
- Obstacles: What might get in the way?
- Front of mind: Is this urgent/important right now?

### Step 2: Create Milestones

Based on the goal, break it down into 3-5 milestones.

Each milestone must have:
- `id`: "m1", "m2", "m3", etc.
- `name`: Short descriptive name
- `description`: Bridge description - "Bridge: From [current state] → [target state]"
- `acceptance_criteria`: Array of 4-8 specific, measurable criteria
- `status`: "pending" (default)
- `progress`: 0 (default)

**Milestone design principles:**
- Each milestone = meaningful checkpoint (20-30% of total work)
- Acceptance criteria must be specific and measurable
- Should be achievable in 3-10 tasks
- Ordered logically (foundation → build → polish)

### Step 3: Create If-Then Rules

For each obstacle identified, create if-then rules:
```json
{
  "condition": "[specific obstacle or problem]",
  "action": "[concrete action to take when this occurs]"
}
```

Examples:
- Scope creep → "Only build features listed in milestones"
- Technical uncertainty → "Start with simplest approach first"
- Perfectionism → "Ship working version in X days, polish later"

### Step 4: Generate Goal ID

Read `dev/agentme/goals.json` and find the highest goal ID number.
New goal ID = `goal-[next number, zero-padded]`

Example: if highest is "goal-004", new ID is "goal-005"

### Step 4.5: Initialize Skills Tracking

**New field: `skillsNeeded`**

This array tracks skills, tools, or capabilities that would help automate work on this goal. It starts empty and gets populated during `/do` when Claude identifies automation opportunities.

**Structure:**
```json
{
  "name": "Skill/tool name",
  "reason": "Why this would help automate work",
  "impact": "high|medium|low",
  "revealedByTasks": ["task-id-1", "task-id-2"],
  "status": "needed|in-progress|acquired",
  "acquiredAt": "ISO timestamp or null"
}
```

**Examples:**
- `{"name": "Deployment MCP", "reason": "Automate staging and production deployments", "impact": "high", ...}`
- `{"name": "Figma Export Tool", "reason": "Auto-export design assets", "impact": "medium", ...}`
- `{"name": "E2E Test Framework", "reason": "Automate integration testing", "impact": "high", ...}`

**When to add:**
- During `/do` when task analysis reveals "need skill" items
- Skills are added automatically by `/do` command
- Human can also add manually when planning

**Initial value:** Empty array `[]`

This creates a **learning loop**: as you work on the goal, the system discovers what skills would increase automation.

### Step 5: Create Goal Object

```json
{
  "id": "goal-XXX",
  "name": "[goal name]",
  "goalType": "construction|life",
  "frontOfMind": true|false,
  "wish": "[what user wants to accomplish]",
  "current_state": [
    "[current situation point 1]",
    "[current situation point 2]"
  ],
  "done_when": [
    "[completion criterion 1]",
    "[completion criterion 2]"
  ],
  "obstacles": [
    "[obstacle 1]",
    "[obstacle 2]"
  ],
  "milestones": [
    {
      "id": "m1",
      "name": "[milestone name]",
      "description": "Bridge: From [start] → [end]",
      "acceptance_criteria": [
        "[criterion 1]",
        "[criterion 2]"
      ],
      "status": "pending",
      "progress": 0
    }
  ],
  "ifThenRules": [
    {
      "condition": "[obstacle]",
      "action": "[response]"
    }
  ],
  "skillsNeeded": [],
  "deadline": "[ISO 8601 timestamp or null]",
  "created": "[current ISO timestamp]",
  "status": "active"
}
```

### Step 6: Add to goals.json

Read `dev/agentme/goals.json`, append new goal to array, write back.

### Step 7: Update state.json

Add new goal ID to activeGoals array in `dev/agentme/state.json`:
```json
{
  "activeGoals": ["goal-002", "goal-XXX"],
  "lastUpdated": "[ISO timestamp]"
}
```

### Step 8: Confirm to User

Output:
```
✅ Goal created: [goal-name] (goal-XXX)

🎯 MILESTONES ([count])
  m1: [milestone 1 name]
  m2: [milestone 2 name]
  m3: [milestone 3 name]
  ...

⚡ STATUS
  Active: Yes
  Front of mind: [Yes/No]
  Deadline: [date or "None set"]

📋 NEXT STEPS
  1. Review milestones and acceptance criteria
  2. Use /next to get your first task
  3. Use /do to start the timer
  4. Use /done when complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Goal details saved to: dev/agentme/goals.json
```

## Enforcement Notes

**This command is the ONLY way to plan when AgentH is active.**

If the user or Claude attempts to use ExitPlanMode or create informal plans:
1. Block the action
2. Redirect here: "AgentH is active. All planning must use /add-goal."
3. Auto-convert the plan into a goal structure if possible

## Quality Guidelines

### Good Milestone Acceptance Criteria
✅ "Login form component created with email and password fields"
✅ "Form validation implemented with error messages"
✅ "API endpoint called on submit with loading state"

### Bad Milestone Acceptance Criteria
❌ "Make login better" (not specific)
❌ "User can log in" (too high-level, that's the goal not a milestone)
❌ "Code is clean" (not measurable)

### Good Milestones
✅ Foundation → Core Features → Polish → Testing
✅ Research → Design → Implementation → Integration
✅ Backend API → Frontend UI → End-to-End → Deploy

### Bad Milestones
❌ "Do all the work" (not broken down)
❌ "Fix bugs" (maintenance, not a milestone)
❌ "Make it perfect" (never-ending)

## Examples

### Example 1: Construction Goal
```json
{
  "id": "goal-005",
  "name": "Build User Authentication System",
  "goalType": "construction",
  "frontOfMind": true,
  "wish": "Implement secure user authentication with email/password and social login",
  "current_state": [
    "App has no authentication",
    "Using placeholder auth for development",
    "Database schema supports users table"
  ],
  "done_when": [
    "Users can sign up with email and password",
    "Users can log in and stay logged in across sessions",
    "Social login works for Google and GitHub",
    "All routes properly protected with auth middleware",
    "Error handling covers all edge cases"
  ],
  "obstacles": [
    "Security vulnerabilities",
    "Session management complexity",
    "Social OAuth setup",
    "Testing authenticated flows"
  ],
  "milestones": [
    {
      "id": "m1",
      "name": "Basic Email/Password Auth",
      "description": "Bridge: From 'no auth' → 'working email/password signup and login'",
      "acceptance_criteria": [
        "User model with email, hashed password, created_at",
        "Signup endpoint validates email format and password strength",
        "Password hashing uses bcrypt with proper salt rounds",
        "Login endpoint returns JWT token on success",
        "Error messages don't leak security info",
        "Unit tests cover happy path and edge cases"
      ],
      "status": "pending",
      "progress": 0
    },
    {
      "id": "m2",
      "name": "Session Management",
      "description": "Bridge: From 'basic auth' → 'persistent sessions with refresh tokens'",
      "acceptance_criteria": [
        "JWT access tokens expire after 15 minutes",
        "Refresh tokens stored securely with 30-day expiry",
        "Token refresh endpoint implemented",
        "Middleware validates JWT on protected routes",
        "Logout properly invalidates tokens",
        "CSRF protection enabled"
      ],
      "status": "pending",
      "progress": 0
    },
    {
      "id": "m3",
      "name": "Social Login Integration",
      "description": "Bridge: From 'email/password only' → 'social login with Google and GitHub'",
      "acceptance_criteria": [
        "OAuth apps configured for Google and GitHub",
        "Social login buttons on signup/login pages",
        "OAuth callback handlers implemented",
        "User accounts linked by email across providers",
        "First-time social login creates user account",
        "Existing users can add social login to account"
      ],
      "status": "pending",
      "progress": 0
    }
  ],
  "ifThenRules": [
    {
      "condition": "Security vulnerabilities",
      "action": "Run security audit with npm audit, use OWASP guidelines, have senior dev review auth code"
    },
    {
      "condition": "Session management complexity",
      "action": "Use battle-tested library (Passport.js or similar), don't roll own crypto"
    },
    {
      "condition": "Social OAuth setup",
      "action": "Follow official provider docs exactly, use environment variables for secrets"
    },
    {
      "condition": "Testing authenticated flows",
      "action": "Create test users, use JWT mocking in tests, maintain separate test database"
    }
  ],
  "skillsNeeded": [],
  "deadline": "2025-11-30T23:59:59Z",
  "created": "2025-11-15T10:00:00Z",
  "status": "active"
}
```

## Template for Quick Copy

```json
{
  "id": "goal-XXX",
  "name": "",
  "goalType": "construction",
  "frontOfMind": false,
  "wish": "",
  "current_state": [],
  "done_when": [],
  "obstacles": [],
  "milestones": [
    {
      "id": "m1",
      "name": "",
      "description": "Bridge: From '' → ''",
      "acceptance_criteria": [],
      "status": "pending",
      "progress": 0
    }
  ],
  "ifThenRules": [],
  "skillsNeeded": [],
  "deadline": null,
  "created": "",
  "status": "active"
}
```
