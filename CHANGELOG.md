# Changelog

All notable documentation changes are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions use `YYYY.MM-N` date-based tags (e.g., `2026.03-1`).

## [Unreleased]

## [2026.03-1] - 2026-03-17

### Added
- Initial docs-only template derived from `ai-dev-template`.
- Triple-agent workflow adapted for documentation roles: Content Strategist, Technical Writer, Reviewer/Validator.
- `triple-agent-docs.yml` — CI workflow for docs validation (structure, links, MkDocs build).
- `docs-publish.yml` — automated publish pipeline to GitHub Pages via MkDocs.
- `mkdocs.yml` — minimal MkDocs configuration with Material theme.
- `docs/index.md` — landing page for the published docs site.
- `docs/CONTRIBUTING.md` — three-role contributing guide, handoff sequence, validation gates.
- `.github/ISSUE_TEMPLATE/docs-request.yml` — structured issue template for documentation requests.
- `scripts/docs-validate.sh` — local Markdown validation and required-file checks.
- `scripts/docs-export-pdf.sh` — best-effort PDF export via pandoc.
- `scripts/docs-changelog.sh` — changelog extraction and formatting script.
- `CLAUDE.md` and `AGENTS.md` — thin adapter files pointing agents to canonical docs.

### Changed
- Replaced software-development agent roles (Codex/Aider/Claude) with documentation-specific roles.
- Replaced `check-fast.yml` and `workflow-conformance.yml` with docs-specific CI workflows.
- Replaced `scripts/check-*.sh` with `scripts/docs-*.sh`.

### Removed
- Runtime and application scaffolding not relevant to a docs-only template.
- Coding-agent prompt packs and implementation workflows.
