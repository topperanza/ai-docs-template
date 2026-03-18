# Contributing to This Documentation

This repository uses a **triple-agent workflow** adapted for documentation production. All contributions — whether from humans or AI agents — follow the same three-role sequence.

---

## The Three Agent Roles

### Role 1: Content Strategist

**Goal:** Ensure the right content gets written for the right audience.

**Responsibilities:**
- Triage incoming `docs-request` issues: assess scope, audience, urgency
- Define the information architecture (IA) for new or revised sections
- Identify coverage gaps: what's missing, what's orphaned, what's out of date
- Produce a scoped outline and acceptance criteria before any writing begins
- Open a PR with the outline in place as a draft so the Technical Writer can proceed

**Outputs:**
- Scoped outline committed to the PR branch
- Acceptance criteria listed in the PR description
- Audience annotation in the draft (who will read this and why)

---

### Role 2: Technical Writer

**Goal:** Transform the outline into clear, correctly formatted, publishable content.

**Responsibilities:**
- Draft or rewrite content per the Content Strategist's outline
- Follow the Markdown style guide (ATX headings, fenced code blocks, consistent admonitions)
- Run `mkdocs serve` locally to confirm rendering before pushing
- Add cross-references and internal links; verify they resolve
- Write code examples with correct syntax highlighting
- Update `CHANGELOG.md` with a summary of changes in the `[Unreleased]` section

**Outputs:**
- Completed Markdown pages committed to the PR branch
- Local `mkdocs build --strict` passing with no warnings
- `CHANGELOG.md` updated

---

### Role 3: Reviewer / Validator

**Goal:** Confirm consistency, link integrity, and merge readiness before merge.

**Responsibilities:**
- Run `bash scripts/docs-validate.sh` and confirm PASS
- Verify all internal links resolve (the `triple-agent-docs.yml` workflow does this automatically)
- Check that the PR description matches actual changes
- Confirm `CHANGELOG.md` entry is present and accurate
- Confirm `mkdocs.yml` nav reflects added or removed pages
- Approve the PR and merge — this triggers the build pipeline (deploy runs only for public repos or opted-in private repos)

**Outputs:**
- PR approval
- Validation report artifact (auto-uploaded by the CI workflow)
- Merged PR → automatic deployment via `docs-publish.yml` (public repos and opted-in private repos; skipped for private repos on GitHub Free)

---

## Handoff Sequence

```
ISSUE (docs-request)
   │
   └── Content Strategist
           - triages issue
           - creates branch: docs/<slug>
           - commits: outline + acceptance criteria
           - opens Draft PR
           │
           └── Technical Writer
                   - drafts content on same branch
                   - runs local build
                   - updates CHANGELOG.md
                   - marks PR Ready for Review
                   │
                   └── Reviewer/Validator
                           - runs scripts/docs-validate.sh
                           - reviews CI results
                           - approves and merges
                           │
                           └── docs-publish.yml (auto)
                                   - builds MkDocs site
                                   - deploys to GitHub Pages
                                     (public repos only; skipped
                                      for private repos on GitHub Free)
```

---

## PR Expectations

All PRs must:

1. **Have a clear description** — what changed, why, which docs-request issue it closes (use `Closes #N`)
2. **Pass all CI checks** — `triple-agent-docs.yml` must complete with no failures
3. **Include a CHANGELOG entry** — in the `[Unreleased]` section of `CHANGELOG.md`
4. **Have an updated nav** — if pages were added or removed, `mkdocs.yml` nav must reflect this
5. **Be reviewed by the Reviewer/Validator role** before merge

---

## Validation Gates

The following gates must pass before a PR can merge:

| Gate | How it runs | Failure behavior |
|---|---|---|
| Markdown structure check | `scripts/docs-validate.sh` in CI | Blocks merge |
| Internal link check | `reviewer_validator` job in CI | Blocks merge |
| MkDocs strict build | `technical_writer` job in CI | Blocks merge |
| CHANGELOG present | `reviewer_validator` job in CI | Blocks merge |
| mkdocs.yml validity | `reviewer_validator` job in CI | Blocks merge |

---

## Handling `docs-request` Issues

When a `docs-request` issue is opened:

1. The `triple-agent-docs.yml` workflow triggers on the `docs-request` label.
2. A Content Strategist (human or agent) picks up the issue within one working day.
3. The Strategist comments on the issue with: scope assessment, proposed outline, estimated pages, and urgency classification.
4. A branch is created (`docs/<issue-slug>`) and a Draft PR opened.
5. The issue remains open until the PR is merged and the content passes all validation gates.

### Issue fields (from the `docs-request` template)

| Field | Purpose |
|---|---|
| Audience | Who will read this content |
| Problem | What question or gap this addresses |
| Scope | Rough page count or section scope |
| Done criteria | Specific definition of done |
| Urgency | Priority for triage |

---

## Local Setup

```bash
# Install deps
pip install mkdocs mkdocs-material mkdocs-git-revision-date-localized-plugin

# Live preview
mkdocs serve

# Validate without building
bash scripts/docs-validate.sh

# Full strict build
mkdocs build --strict
```

---

## Style Guide (Summary)

- Use ATX-style headings (`#`, `##`, `###`) — no underline style
- Use fenced code blocks with language annotations (` ```bash `, ` ```python `, etc.)
- Prefer active voice and second person ("you") for procedural docs
- One sentence per line in source Markdown (easier diffs)
- All images go in `docs/assets/` with descriptive alt text
- Internal links use relative paths from the current file
- External links open in current tab (no `{target="_blank"}` unless essential)
