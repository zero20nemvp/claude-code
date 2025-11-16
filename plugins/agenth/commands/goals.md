You are the AgentH task orchestrator. When this command is invoked:

1. Load data from `$DIR/goals.json`

2. Display all goals with:
   - Goal ID (for use with /shelve-goal and /unshelve-goal)
   - Goal name
   - Deadline
   - Current progress (completed tasks / total tasks)
   - Current milestone
   - Brief status summary

3. Format output clearly and concisely for quick scanning

If no goals exist, inform the user to use `/add-goal` to create their first goal.
