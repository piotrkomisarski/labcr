---
name: linear
description: Processes Linear issues/tasks through a multi-agent workflow. Use when user provides a Linear issue ID (like LIN-123, ABC-456) or asks to work on a Linear task. Fetches issue details, explores codebase, plans implementation, executes, and reviews code.
---

# Linear Task Workflow

This skill orchestrates a complete development workflow for Linear issues using specialized sub-agents.

## Trigger Patterns

Activate this skill when user:
- Provides a Linear issue ID (e.g., `LIN-123`, `TEAM-456`)
- Says "work on Linear task...", "implement issue...", "do Linear..."
- Mentions processing or implementing a Linear issue
- Says "weź task", "następny task", "daj coś do roboty" (no specific ID provided)

## Workflow Steps

### Step 0: Find Issue (if no ID provided)

If user didn't provide a specific issue ID:

1. Use `mcp__plugin_linear_linear__list_issues` with:
   - `state: "Todo"` (or "Backlog", "Ready" - check available statuses)
   - `limit: 1`
   - `orderBy: "updatedAt"` (most recently updated first)

2. Briefly announce which issue you're taking and immediately proceed to Step 1 (no confirmation needed)

Example:
```
User: weź jakiś task
Claude: [calls list_issues with state="Todo", limit=1]
        Biorę LAB-45 "Add dark mode toggle"
        [immediately proceeds to Step 1]
```

### Step 1: Fetch Issue Details

Use `mcp__plugin_linear_linear__get_issue` to retrieve:
- Title and description
- Acceptance criteria
- Labels and priority
- Related issues and attachments (including existing PR links!)

Display a brief summary.

### Step 1.5: Check for Existing PR

**IMPORTANT:** Before creating a new branch, check if there's already a PR for this task.

1. Check the issue attachments for existing PR links (format: `https://github.com/.../pull/N`)
2. If PR exists, run:
   ```bash
   gh pr view {pr_number} --json number,state,headRefName,comments
   ```
3. Check PR state and comments for context/feedback

**If existing PR is found (state=OPEN):**
- Switch to the existing branch: `git checkout {branch_name}`
- Pull latest changes: `git pull`
- Read PR comments to understand what changes are requested
- Skip to Step 5 (Implement Changes) - but implement only the requested changes
- After implementation, push to existing branch (Step 7 alternate flow)

**If no existing PR or PR is closed/merged:**
- Proceed with normal flow (Step 2: Explore Codebase)

### Step 2: Explore Codebase

Launch `Task` with `subagent_type=Explore` to:
- Find relevant files and modules
- Understand existing patterns and architecture
- Identify where changes need to be made
- Look for similar implementations to follow

Be thorough - use "very thorough" exploration level.

### Step 3: Plan Implementation

Launch `Task` with `subagent_type=Plan` to:
- Design implementation approach
- Identify files to create/modify
- Consider edge cases
- Note potential risks

Proceed immediately to branch creation.

### Step 4: Create Feature Branch

Before implementing, create a new git branch:
```bash
git checkout -b LIN-{issue_number}
```

Example: For issue `ABC-123`, create branch `ABC-123`.

Use the issue identifier exactly as provided (e.g., `LAB-45`, `TEAM-789`).

### Step 5: Implement Changes

Based on the plan:
- Create/modify files as planned
- Follow existing code patterns
- Keep changes minimal and focused
- Use TodoWrite to track progress

### Step 6: Code Review (with fix loop)

Launch `Task` with `subagent_type=code-reviewer` to:
- Review all changes for quality
- Check adherence to project guidelines
- Identify potential issues
- Suggest improvements

**If issues are found:**
1. Fix all identified problems immediately
2. Re-run code-reviewer to verify fixes
3. Repeat until no issues remain (max 3 iterations)

Only proceed to Step 6.5 when review passes clean.

### Step 6.5: Simplify Code

After code review passes, launch `Task` with `subagent_type=pr-review-toolkit:code-simplifier` to:
- Identify opportunities to simplify the implementation
- Remove unnecessary complexity
- Suggest more concise approaches

Apply any valid simplifications, then proceed to Step 7.

### Step 7: Commit, Push & Create Pull Request

After code review passes:

#### Flow A: New PR (no existing PR)

1. **Commit all changes:**
   ```bash
   git add .
   git commit -m "LIN-{issue_number}: {issue_title}"
   ```

2. **Push branch to remote:**
   ```bash
   git push -u origin LIN-{issue_number}
   ```

3. **Create Pull Request:**
   ```bash
   gh pr create --title "LIN-{issue_number}: {issue_title}" --body "..."
   ```

   PR body should include:
   - Link to Linear issue
   - Summary of changes
   - Files modified

   Save the PR URL and PR number for later steps.

4. **Wait for Netlify Deploy Preview:**
   - Wait 30 seconds for Netlify to create deploy preview
   - Use `gh pr view {pr_number} --comments --json comments` to fetch PR comments
   - Find comment from Netlify (usually contains "netlify" and deploy preview URL)
   - Extract the deploy preview URL (format: `https://deploy-preview-{pr_number}--{site}.netlify.app`)
   - Save this URL for Slack notification

5. **Switch to master branch:**
   ```bash
   git checkout master
   ```

#### Flow B: Updating Existing PR

If working on an existing PR (from Step 1.5):

1. **Commit changes with descriptive message:**
   ```bash
   git add .
   git commit -m "LIN-{issue_number}: Address review feedback - {brief description}"
   ```

2. **Push to existing branch:**
   ```bash
   git push
   ```
   (No need for -u flag, branch already tracks remote)

3. **No need to create PR** - it already exists!

4. **Wait for Netlify Deploy Preview:**
   - Wait 30 seconds for new deploy
   - Fetch deploy preview URL from PR comments (same as Flow A)

5. **Switch to master branch:**
   ```bash
   git checkout master
   ```

### Step 8: Update Linear (MANDATORY)

**ALWAYS** update the Linear issue after PR is created/updated:

1. **Add PR link as attachment** (if new PR):
   ```
   mcp__plugin_linear_linear__update_issue with links parameter
   ```

2. **Change status to "In Review"**:
   ```
   mcp__plugin_linear_linear__update_issue with state: "In Review"
   ```

⚠️ **IMPORTANT:**
- Do NOT set status to "Done" - always use "In Review"
- The task is NOT complete until someone reviews and merges the PR
- Only a human reviewer should move the issue to "Done" after PR is merged

### Step 9: Send Slack Summary (MANDATORY - DO NOT SKIP!)

⚠️ **THIS STEP IS REQUIRED** - The workflow is NOT complete until Slack notification is sent!

Use `mcp__slack__slack_post_message` to send a completion summary to the `#better-stack` channel.

**Use channel ID directly:** `C0A70D07N4S` (do not search for the channel).

Post a message with:
- Issue ID and title
- Brief summary of changes made
- Files modified/created
- **Link to Pull Request** (important!)
- **Link to Deploy Preview** (from Netlify comment!)
- Link to Linear issue

Use a concise format, e.g.:

**For new PR:**
```
:white_check_mark: LIN-123 "Add user authentication" - Done!

Changes:
- Created src/auth/AuthService.ts
- Modified src/middleware/index.ts
- Added 3 tests

PR: https://github.com/org/repo/pull/42
Deploy Preview: https://deploy-preview-42--mysite.netlify.app
Linear: https://linear.app/team/issue/LIN-123
```

**For PR update (review feedback):**
```
:arrows_counterclockwise: LIN-123 "Add user authentication" - Updated!

Review feedback addressed:
- Added loading state
- Fixed error handling

PR: https://github.com/org/repo/pull/42
Deploy Preview: https://deploy-preview-42--mysite.netlify.app
Linear: https://linear.app/team/issue/LIN-123
```

## Example Interaction

### With issue ID:
```
User: LIN-123

Claude: [Fetches issue details]
        Issue LIN-123: "Add user authentication"
        Priority: High
        Description: Implement JWT-based auth...

        [Runs Explore agent]
        Found relevant files:
        - src/auth/...
        - src/middleware/...

        [Runs Plan agent]
        Implementation plan:
        1. Create AuthService...
        2. Add middleware...

        [Creates branch LIN-123]
        git checkout -b LIN-123

        [Implements changes, tracks with TodoWrite]

        [Runs code-reviewer]
        Found 2 issues: missing error handling, inconsistent naming

        [Fixes issues]

        [Re-runs code-reviewer]
        All clear!

        [Commits and pushes]
        git commit -m "LIN-123: Add user authentication"
        git push -u origin LIN-123

        [Creates PR]
        PR #42 created: https://github.com/org/repo/pull/42

        [Waits 30 seconds for Netlify deploy preview]

        [Fetches PR comments, finds Netlify deploy preview link]
        Deploy Preview: https://deploy-preview-42--mysite.netlify.app

        [Switches to master branch]
        git checkout master

        [Sends Slack summary with PR + Deploy Preview links]
        Posted to Slack

        Done!
```

### Without issue ID (auto-pick from backlog):
```
User: weź jakiś task

Claude: [Calls list_issues with state="Todo", limit=1]
        Biorę LAB-45 "Add dark mode toggle"
        [Immediately fetches full issue details]
        [Runs Explore agent]
        [Runs Plan agent]
        [Creates branch LAB-45]
        [Implements, reviews, commits, pushes, creates PR]
        [Waits 30s, fetches Netlify deploy preview from PR comments]
        [Switches to master]
        [Sends Slack summary with PR + Deploy Preview]
        Done!
```

### Updating existing PR (review feedback):
```
User: LAB-123

Claude: [Fetches issue details]
        Issue LAB-123: "Add user profile page"
        Found existing PR: #42

        [Fetches PR comments]
        gh pr view 42 --json number,state,headRefName,comments

        Review feedback found:
        - "Please add loading state"
        - "Missing error handling"

        [Checks out existing branch]
        git checkout LAB-123
        git pull

        [Implements requested changes only]
        - Added loading spinner
        - Added try/catch error handling

        [Runs code-reviewer]
        All clear!

        [Commits and pushes to existing branch]
        git commit -m "LAB-123: Address review feedback - add loading state and error handling"
        git push

        [Waits 30s, fetches new Netlify deploy preview]
        Deploy Preview: https://deploy-preview-42--mysite.netlify.app

        [Switches to master]
        git checkout master

        [Sends Slack summary]
        Posted update to Slack

        Done!
```

## Configuration

### Slack Channel
Always send summary to the `#better-stack` channel using channel ID `C0A70D07N4S` directly (the bot is added there).

**IMPORTANT:** Use the channel ID directly in the `mcp__slack__slack_post_message` call:
```
channel_id: "C0A70D07N4S"
```

Do NOT try to look up the channel by name - use the ID directly.

## Important Notes

- Execute the full workflow autonomously without waiting for confirmations
- Keep the user informed at each step
- If issue description is unclear, ask clarifying questions
- Follow project conventions from CLAUDE.md
- **Always check for existing PR first** - if task already has a PR, update it instead of creating a new one
- When updating existing PR, read comments carefully to understand what changes are requested

## ⚠️ COMPLETION CHECKLIST (VERIFY BEFORE SAYING "Done!")

Before marking the task as complete, verify ALL items:

- [ ] Code implemented and reviewed
- [ ] Code simplified with code-simplifier
- [ ] Changes committed and pushed
- [ ] PR created or updated
- [ ] Switched back to master branch
- [ ] **LINEAR STATUS SET TO "In Review"** ← Call `mcp__plugin_linear_linear__update_issue` with `state: "In Review"`
- [ ] **SLACK NOTIFICATION SENT** ← Call `mcp__slack__slack_post_message` with channel_id `C0A70D07N4S`

🚨 **MANDATORY STEPS - DO NOT SKIP:**

1. **Linear status = "In Review"** (NEVER "Done"!)
   ```
   mcp__plugin_linear_linear__update_issue(id: "...", state: "In Review", links: [...])
   ```

2. **Slack notification to #better-stack**
   ```
   mcp__slack__slack_post_message(channel_id: "C0A70D07N4S", text: "...")
   ```

🛑 **THE WORKFLOW IS NOT COMPLETE UNTIL BOTH ARE DONE!**
