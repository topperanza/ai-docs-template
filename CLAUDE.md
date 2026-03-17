# CLAUDE.md

Read first:
- docs/CONTRIBUTING.md  — three-role workflow, handoff sequence, validation gates

Current task state:
- HANDOFF.md (if present)

Repo reminders:
- This is a docs-only template — no runtime or application code
- Three roles: Content Strategist, Technical Writer, Reviewer/Validator
- Always run `bash scripts/docs-validate.sh` before committing
- Run `mkdocs build --strict` locally to confirm rendering
- Keep `mkdocs.yml` nav in sync with added/removed pages
- CHANGELOG.md must be updated in [Unreleased] before any merge
- No secrets in tracked files
