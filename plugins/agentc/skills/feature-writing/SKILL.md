---
name: feature-writing
description: Use after story mapping or when you have user stories to convert into executable Gherkin feature files. Sets up Cucumber if needed and writes scenarios with step definitions.
---

# Feature Writing

## Overview

Write executable Gherkin feature files from user stories with proper Cucumber setup.

**Announce at start:** "I'm using the feature-writing skill to write Gherkin feature files from the user stories."

Read stories from the stories document (or accept inline), then generate .feature files with scenarios. Present each feature for validation before writing.

## The Process

**Loading context:**
- Read the stories document if available (docs/stories/*.md)
- Check if Cucumber is already set up in the project
- Identify existing step definitions to reuse

**Cucumber setup (if not present):**

For Rails projects:
1. Add to Gemfile: gem 'cucumber-rails', require: false
2. Add to Gemfile: gem 'database_cleaner-active_record'
3. Run: bundle install
4. Run: rails generate cucumber:install
5. Verify: features/ directory created with support files

**Writing features (one at a time):**
- Take each user story
- Write the Feature header (As a/I want/So that)
- Write scenarios from acceptance criteria
- Present for validation before saving
- Ask: "Does this feature capture the behavior correctly?"

## Feature File Format

    Feature: [Story title]
      As a [role]
      I want [capability]
      So that [benefit]

      Scenario: [Happy path description]
        Given [precondition]
        When [action]
        Then [expected outcome]

      Scenario: [Edge case description]
        Given [different precondition]
        When [action]
        Then [different outcome]

## Three-Tier Quality

Apply milk quality tiers to scenario coverage:

**Skimmed:** Happy path only
- One scenario covering the main success path
- Minimal but functional

**Semi-skimmed (default):** Happy + essential edge cases
- Happy path scenario
- Key error cases (invalid input, not found, unauthorized)
- 3-5 scenarios total

**Full phat:** Comprehensive coverage
- Happy path scenario
- All edge cases
- Error scenarios
- Boundary conditions
- 6+ scenarios

## Step Definition Strategy

**Reuse existing steps:** Check features/step_definitions/ for reusable steps

**Write new steps:** Create in features/step_definitions/[feature]_steps.rb

Step definition pattern for Rails:

    Given('I am logged in as {string}') do |role|
      # Implementation using factory or fixture
    end

    When('I visit the {string} page') do |page_name|
      visit path_for(page_name)
    end

    Then('I should see {string}') do |text|
      expect(page).to have_content(text)
    end

**Step writing principles:**
- Declarative over imperative (describe what, not how)
- Reusable across features
- Business language, not technical details

## Output

Write feature files to: features/[feature_name].feature
Write step definitions to: features/step_definitions/[feature]_steps.rb

## Verification

After writing each feature:
1. Run: bundle exec cucumber features/[feature_name].feature --dry-run
2. Verify syntax is valid
3. Identify any missing step definitions
4. Write missing steps before moving on

## After Writing

**If continuing to slicing:**
- Ask: "Ready to plan vertical slices and create worktrees?"
- Use superpowers:vertical-slicing to plan implementation

**If stopping here:**
- Commit feature files to git
- Features can be picked up later with /vertical-slicing

## Key Principles

- **One feature at a time** - Validate before moving on
- **Declarative scenarios** - Describe behavior, not clicks
- **Reuse steps** - Check existing steps before writing new ones
- **Tier-appropriate coverage** - Match scenario count to quality tier
- **Executable specs** - These are tests, they must run
- **Business language** - Stakeholders should understand scenarios

## Integration

**Called by:**
- superpowers:story-mapping (after story derivation)
- superpowers:product-discovery (Phase 3)

**Chains to:**
- superpowers:vertical-slicing (plan implementation slices)

**Uses:**
- superpowers:test-driven-development (TDD discipline for step definitions)
