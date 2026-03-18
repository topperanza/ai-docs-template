# Public Pages Profile

Use this profile when your repo is **public on GitHub** and you want to publish the docs site to GitHub Pages automatically.

---

## What this profile provides

- Automated deployment to GitHub Pages on every merge to `main`
- A public URL at `https://<owner>.github.io/<repo>/`
- The full triple-agent CI/CD pipeline: validate → build → deploy

---

## Prerequisites

| Requirement | Where to configure |
|---|---|
| Repository visibility set to **Public** | GitHub → Settings → General |
| GitHub Pages source set to **GitHub Actions** | GitHub → Settings → Pages → Source |
| `site_url` in `mkdocs.yml` updated to your Pages URL | `mkdocs.yml` |

---

## Enabling Pages

1. Go to your repository's **Settings → Pages**.
2. Under **Source**, select **GitHub Actions**.
3. Save.

The next merge to `main` that touches docs will trigger `docs-publish.yml`, which builds the site and deploys it automatically.

---

## Deploy trigger

Deployment is automatic on push to `main` for paths matching:

```
docs/**
README.md
CHANGELOG.md
mkdocs.yml
scripts/docs-*
```

To force a deploy without a docs change, use **Actions → docs-publish → Run workflow** and set `force_publish: true`.

---

## Important: Pages site visibility

**A GitHub Pages site is always publicly accessible**, even if the source repository is private on a paid GitHub plan.
Before enabling Pages, confirm you are comfortable with the docs content being publicly visible.

---

## What to keep from the template

Keep all files as-is.
No additional configuration beyond the prerequisites above is needed for this profile.

---

## Related

- [Private / Local Build Profile](private-local.md) — if you later change visibility or move to a private repo
