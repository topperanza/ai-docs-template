# Private / Local Build Profile

Use this profile when your repo is **private** — including GitHub Free private repos — and you do not need to publish to GitHub Pages.

---

## What this profile provides

- Full CI validation on every PR: Markdown structure, internal links, strict MkDocs build
- Local build and PDF export via scripts
- Downloadable `docs-site-bundle` artifact on every merge to `main`
- No dependency on GitHub Pages being enabled

---

## What happens automatically

The `deploy` job in `docs-publish.yml` is skipped when the repository is private and the `ENABLE_PAGES_DEPLOY` variable is not set.
The `build` job still runs on every qualifying merge and uploads a `docs-site-bundle` artifact.

After a merge to `main`, go to **Actions → docs-publish** to confirm:

- `Build docs site` — should show green
- `Deploy to GitHub Pages` — should show as skipped, not failed

---

## Using the built site locally

Download the `docs-site-bundle` artifact from the Actions run, or build locally:

```bash
pip install mkdocs mkdocs-material
mkdocs build --strict
```

The built site is in `site/`.
Open `site/index.html` in a browser, or serve with any static file server:

```bash
python -m http.server 8000 --directory site/
```

---

## Live preview during writing

```bash
mkdocs serve
```

Starts a live-reload preview at `http://127.0.0.1:8000`.

---

## Exporting to PDF

```bash
bash scripts/docs-export-pdf.sh
```

Requires `pandoc` installed locally.
The script exits cleanly if pandoc is not available — it is non-blocking.

---

## Validation gates (all remain active)

All PR validation gates work regardless of Pages availability:

| Gate | Status |
|---|---|
| Markdown structure check | Active |
| Internal link check | Active |
| MkDocs strict build | Active |
| CHANGELOG present | Active |

---

## Enabling Pages later

If you move to a paid GitHub plan and want to publish to Pages:

1. Go to **Settings → Secrets and variables → Actions → Variables**.
2. Add a repository variable named `ENABLE_PAGES_DEPLOY` with value `true`.
3. Enable GitHub Pages under **Settings → Pages → Source: GitHub Actions**.

> **Note:** A GitHub Pages site is always publicly accessible, even if the source repository is private.
> Confirm the docs content is appropriate for public access before enabling.

---

## Related

- [Public Pages Profile](public-pages.md) — for public repos with full Pages deployment
