---
description: "Comprehensive PR review using specialized agents. Usage: /review-pr [aspects] [parallel]"
argument-hint: "[comments|tests|errors|types|code|simplify|all] [parallel]"
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Task"]
---

# Comprehensive PR Review

Run a comprehensive pull request review using multiple specialized agents, each focusing on a different aspect of code quality.

**Arguments:** "$ARGUMENTS"

## Review Workflow

### 1. Determine Review Scope

```bash
# Check changed files
git diff --name-only

# Check for existing PR
gh pr view 2>/dev/null || echo "No PR yet"
```

Parse arguments for specific review aspects. Default: Run all applicable.

### 2. Available Review Aspects

| Aspect | Agent | Focus |
|--------|-------|-------|
| `comments` | comment-analyzer | Comment accuracy and maintainability |
| `tests` | pr-test-analyzer | Test coverage quality and completeness |
| `errors` | silent-failure-hunter | Error handling for silent failures |
| `types` | type-design-analyzer | Type design and invariants |
| `code` | code-reviewer | General code quality and CLAUDE.md compliance |
| `simplify` | code-simplifier | Code clarity and maintainability |
| `all` | All applicable | Default - runs all agents |

### 3. Determine Applicable Reviews

Based on changes:
- **Always**: code-reviewer (general quality)
- **If test files changed**: pr-test-analyzer
- **If comments/docs added**: comment-analyzer
- **If error handling changed**: silent-failure-hunter
- **If types added/modified**: type-design-analyzer
- **After passing review**: code-simplifier (polish)

### 4. Launch Review Agents

**Sequential (default)**: One at a time, easier to act on
**Parallel (if requested)**: All simultaneously, faster

Use the Task tool to dispatch appropriate agents.

### 5. Aggregate Results

After agents complete, summarize:

```markdown
# PR Review Summary

## Critical Issues (X found)
- [agent-name]: Issue description [file:line]

## Important Issues (X found)
- [agent-name]: Issue description [file:line]

## Suggestions (X found)
- [agent-name]: Suggestion [file:line]

## Strengths
- What's well-done in this PR

## Recommended Action
1. Fix critical issues first
2. Address important issues
3. Consider suggestions
4. Re-run review after fixes
```

## Usage Examples

**Full review (default):**
```
/review-pr
```

**Specific aspects:**
```
/review-pr tests errors
/review-pr comments
/review-pr simplify
```

**Parallel review:**
```
/review-pr all parallel
```

## Workflow Integration

**Before committing:**
1. Write code
2. Run: `/review-pr code errors`
3. Fix critical issues
4. Commit

**Before creating PR:**
1. Run: `/review-pr all`
2. Address critical and important issues
3. Re-run to verify
4. Create PR

**After PR feedback:**
1. Make requested changes
2. Run targeted reviews
3. Verify resolved
4. Push updates

## Notes

- Agents run autonomously and return detailed reports
- Each agent focuses on its specialty for deep analysis
- Results are actionable with specific file:line references
- Agents use appropriate models for their complexity
