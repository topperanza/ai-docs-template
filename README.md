# ai-docs-template

A documentation-focused GitHub template that applies the **triple-agent workflow** to docs production — replacing coding-agent roles with Content Strategist, Technical Writer, and Reviewer/Validator.

Built on [MkDocs](https://www.mkdocs.org/) + [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).
Supports public GitHub Pages deployment and private/local-only builds from the same template.

---

## Purpose

This template is for teams that want to use multi-agent AI workflows not for software development, but for **creating, reviewing, and publishing documentation**. It provides:

- A three-role agent workflow tailored to docs production
- Automated validation on every pull request (link checks, structure, style)
- Automated build and validation on every merge to `main`; GitHub Pages deployment for public repos (see [Deployment Profiles](#deployment-profiles))
- Scripts for local validation, PDF export, and changelog management
- Issue templates for structured docs requests

---

## The Three Agent Roles

### 1. Content Strategist

**Responsibility:** Information architecture, coverage gaps, and audience alignment.

- Reviews incoming docs-request issues and PRs for scope and audience fit
- Identifies missing pages, orphaned content, and navigation gaps
- Defines the outline and acceptance criteria before writing begins
- Maps content to the intended audience (end users, contributors, operators)

### 2. Technical Writer

**Responsibility:** Drafting, formatting, and style.

- Writes or rewrites content per the outline from the Content Strategist
- Enforces Markdown formatting rules and the project style guide
- Builds the MkDocs site locally to confirm rendering
- Handles code examples, callouts, admonitions, and cross-references

### 3. Reviewer / Validator

**Responsibility:** Consistency, link integrity, and merge readiness.

- Runs `scripts/docs-validate.sh` to check Markdown and structure
- Verifies all internal links resolve
- Confirms CHANGELOG.md is updated for the release
- Approves the PR and merges — triggers the build pipeline; deploy runs only for public repos or opted-in private repos

---

## Workflow Overview

```
docs-request issue
       │
       ▼
Content Strategist  →  scopes, outlines, creates PR
       │
       ▼
Technical Writer    →  drafts content, local mkdocs build
       │
       ▼
Reviewer/Validator  →  validates, approves, merges
       │
       ▼
docs-publish.yml    →  builds site (all repos)
                       deploys to GitHub Pages (public repos / paid opt-in)
```

---

## Local Validation Commands

```bash
# Validate Markdown structure and required files
bash scripts/docs-validate.sh

# Build the MkDocs site locally (requires mkdocs installed)
mkdocs serve          # live preview at http://127.0.0.1:8000
mkdocs build --strict # one-shot build; fails on warnings

# Export docs to PDF via pandoc (best-effort)
bash scripts/docs-export-pdf.sh

# View formatted changelog
bash scripts/docs-changelog.sh
```

Install dependencies:

```bash
pip install mkdocs mkdocs-material mkdocs-git-revision-date-localized-plugin
```

---

## Deployment Profiles

This template supports two profiles from a single shared codebase.
Choose based on your repository visibility.

### Public Pages (public repos)

Public repositories get full automatic Pages deployment.
The `deploy` job in `docs-publish.yml` runs when `github.event.repository.visibility == 'public'`.

Required setup: enable **GitHub Pages → Source: GitHub Actions** in your repository settings.
See [docs/setup/public-pages.md](docs/setup/public-pages.md).

### Private / Local Build (GitHub Free private repos)

Private repos on GitHub Free do not have GitHub Pages access.
The `deploy` job is automatically skipped — the `build` job still runs and uploads a `docs-site-bundle` artifact.
All PR validation gates remain active.

See [docs/setup/private-local.md](docs/setup/private-local.md).

### Private repo on a paid plan

Set repository variable `ENABLE_PAGES_DEPLOY` to `true` and enable Pages under **Settings → Pages → Source: GitHub Actions**.

> **Note:** A GitHub Pages site is always publicly accessible, even if the source repository is private.

---

## Publish Flow

1. Merge a PR to `main` that touches `docs/**`, `mkdocs.yml`, or `CHANGELOG.md`.
2. `docs-publish.yml` triggers automatically.
3. The **build** job runs `mkdocs build --strict`, generates a changelog artifact, and attempts a PDF export via pandoc.
4. The **deploy** job publishes to GitHub Pages — **only for public repos** (or when `ENABLE_PAGES_DEPLOY` is set).
5. The deployed URL is reported in the workflow summary.

To force-publish without a docs change: use the `workflow_dispatch` trigger with `force_publish: true`.

---

## Platform

| Component | Technology |
|---|---|
| Docs site | MkDocs + Material theme |
| Hosting | GitHub Pages (public repos); local / CI artifact (private repos) |
| Validation | Custom shell scripts + GitHub Actions |
| PDF export | pandoc (best-effort) |
| CI | GitHub Actions (triple-agent-docs.yml, docs-publish.yml) |

---

## Getting Started

1. Update `mkdocs.yml` — set `site_name`, `site_url`, and `repo_url` for your repo.
2. Replace `docs/index.md` with your project's landing page content.
3. Update `docs/CONTRIBUTING.md` with your team's workflow details.
4. Choose your deployment profile:
   - **Public repo:** Enable GitHub Pages → Settings → Pages → Source: GitHub Actions.
   - **Private repo on GitHub Free:** No Pages setup needed — build artifacts are available in CI. See [docs/setup/private-local.md](docs/setup/private-local.md).
