# AGENTS.md

Start here:
- docs/CONTRIBUTING.md  — three-role workflow, handoff sequence, validation gates

Validation order:
1. bash scripts/docs-validate.sh
2. mkdocs build --strict (if mkdocs installed)
3. bash scripts/docs-changelog.sh --unreleased
4. Review CI artifacts: validation-report, docs-site-preview

Three agent roles:
1. Content Strategist  — scope, IA, coverage, audience
2. Technical Writer    — draft, format, style, mkdocs build
3. Reviewer/Validator  — consistency, links, CHANGELOG, publish gate

Agent routing:
- Codex is the default primary agent across all three documentation roles
- Codex implements, validates, and commits locally on a feature branch
- Claude is optional for review and risk checks when access exists
- Aider is optional for targeted narrow patches

Final branch PR handoff:
1. Codex writes the PR body to `/tmp/<repo>-pr.md`
2. Codex does not push or open the PR by default
3. Codex reports exactly:
   `gh-pr-ready "<PR title>" /tmp/<repo>-pr.md main`
4. The operator reviews Codex's final report, then runs the helper manually
5. Keep one PR per repository

`gh-pr-ready` is an operator-local helper, not repository code.

Non-negotiables:
- No secrets in tracked files
- Always update CHANGELOG.md [Unreleased] before merging
- mkdocs.yml nav must reflect actual pages
- Do not bypass CI validation gates
