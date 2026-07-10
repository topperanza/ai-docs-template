# CLAUDE.md

Read first:
- docs/CONTRIBUTING.md  — three-role workflow, handoff sequence, validation gates

Current task state:
- HANDOFF.md (if present)

Repo reminders:
- This is a docs-only template — no runtime or application code
- Three roles: Content Strategist, Technical Writer, Reviewer/Validator
- Codex is the default primary agent for implementation, validation, local commits, and PR handoff preparation
- Claude is optional for review and risk checks when access exists
- Aider is optional for targeted narrow patches
- Always run `bash scripts/docs-validate.sh` before committing
- Run `mkdocs build --strict` locally to confirm rendering
- Keep `mkdocs.yml` nav in sync with added/removed pages
- CHANGELOG.md must be updated in [Unreleased] before any merge
- For branch-based work, Codex writes `/tmp/<repo>-pr.md` and reports `gh-pr-ready "<PR title>" /tmp/<repo>-pr.md main`
- Codex does not push or open the PR by default; the operator reviews the final report and runs the operator-local helper manually
- Keep one PR per repository
- No secrets in tracked files
