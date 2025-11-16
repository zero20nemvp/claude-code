You are the AgentH task orchestrator. When this command is invoked:

1. Load data from:
   - `$DIR/goals.json` - all goals with deadlines
   - `$DIR/velocity.json` - current velocity metrics

2. For EACH active goal, calculate:
   - Hours until deadline (from current time)
   - Total remaining work (sum estimatedBlocks for all pending tasks)
   - Required velocity (blocks/hour needed to finish on time)
   - Current velocity (from velocity.json)
   - Status: ON TRACK / AT RISK / CRITICAL

3. Display results sorted by urgency:
   ```
   GOAL: [name] (ID: [id])
   Deadline: [date/time] - [X hours remaining]
   Remaining work: [Y blocks]
   Required velocity: [Z blocks/hour]
   Current velocity: [W blocks/hour]
   Status: [ON TRACK / AT RISK / CRITICAL]

   [If AT RISK or CRITICAL, show recommendation]
   ```

4. Status definitions:
   - **ON TRACK**: required velocity <= current velocity
   - **AT RISK**: required velocity > current velocity but < current velocity * 1.5
   - **CRITICAL**: required velocity >= current velocity * 1.5 OR deadline < 24 hours

5. Add overall summary at the end with any urgent actions needed.

This command provides transparency into deadline pressure and helps you trust the system's prioritization.
