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

Non-negotiables:
- No secrets in tracked files
- Always update CHANGELOG.md [Unreleased] before merging
- mkdocs.yml nav must reflect actual pages
- Do not bypass CI validation gates
