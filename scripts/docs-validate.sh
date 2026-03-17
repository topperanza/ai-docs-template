#!/usr/bin/env bash
# docs-validate.sh
# Validates Markdown structure, required files, and basic formatting.
# Run locally before committing or let CI run it automatically.
# Exit code: 0 = PASS, 1 = FAIL
set -euo pipefail

ERRORS=0
WARNINGS=0
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log_err()  { echo "ERROR:   $*"; ERRORS=$((ERRORS + 1)); }
log_warn() { echo "WARNING: $*"; WARNINGS=$((WARNINGS + 1)); }
log_ok()   { echo "OK:      $*"; }

echo "=== docs-validate.sh ==="
echo "Root: $ROOT"
echo ""

# ── 1. Required files ────────────────────────────────────────────────────────
echo "--- Required files ---"
required_files=(
  "docs/index.md"
  "docs/CONTRIBUTING.md"
  "mkdocs.yml"
  "CHANGELOG.md"
  "CLAUDE.md"
  "AGENTS.md"
)

for f in "${required_files[@]}"; do
  if [[ -f "$ROOT/$f" ]]; then
    log_ok "$f exists"
  else
    log_err "$f is MISSING"
  fi
done
echo ""

# ── 2. docs/ directory check ─────────────────────────────────────────────────
echo "--- docs/ directory ---"
if [[ -d "$ROOT/docs" ]]; then
  md_count=$(find "$ROOT/docs" -name "*.md" | wc -l | tr -d ' ')
  log_ok "docs/ found with ${md_count} Markdown file(s)"
else
  log_err "docs/ directory not found"
fi
echo ""

# ── 3. Markdown heading checks ───────────────────────────────────────────────
echo "--- Markdown heading checks ---"
while IFS= read -r mdfile; do
  relfile="${mdfile#"$ROOT/"}"

  # Check: file has at least one heading
  if ! grep -qE '^\#{1,6} ' "$mdfile"; then
    log_warn "$relfile has no headings"
  fi

  # Check: no bare <html> tags (common paste error)
  if grep -qE '<(script|style|iframe)' "$mdfile"; then
    log_err "$relfile contains potentially unsafe HTML tags (<script>, <style>, <iframe>)"
  fi

  # Check: no trailing whitespace on heading lines (cosmetic but caught early)
  if grep -qE '^\#{1,6} .*[[:space:]]$' "$mdfile"; then
    log_warn "$relfile has trailing whitespace on a heading line"
  fi
done < <(find "$ROOT/docs" -name "*.md" 2>/dev/null)
echo ""

# ── 4. CHANGELOG [Unreleased] section check ──────────────────────────────────
echo "--- CHANGELOG ---"
if [[ -f "$ROOT/CHANGELOG.md" ]]; then
  if grep -q '## \[Unreleased\]' "$ROOT/CHANGELOG.md"; then
    log_ok "CHANGELOG.md has [Unreleased] section"
  else
    log_warn "CHANGELOG.md has no [Unreleased] section — consider adding one"
  fi
else
  log_err "CHANGELOG.md not found"
fi
echo ""

# ── 5. mkdocs.yml basic syntax check ─────────────────────────────────────────
echo "--- mkdocs.yml ---"
if [[ -f "$ROOT/mkdocs.yml" ]]; then
  if command -v python3 &>/dev/null; then
    result=$(python3 -c "
try:
    import yaml
except ImportError:
    print('NO_YAML_MODULE')
    exit(0)
import sys
with open('$ROOT/mkdocs.yml') as f:
    cfg = yaml.safe_load(f)
required_keys = ['site_name', 'docs_dir']
missing = [k for k in required_keys if k not in cfg]
if missing:
    print('MISSING_KEYS: ' + ', '.join(missing))
    sys.exit(0)
print('VALID')
" 2>&1) || true
    if [[ "$result" == "VALID" ]]; then
      log_ok "mkdocs.yml is valid YAML with required keys"
    elif [[ "$result" == "NO_YAML_MODULE" ]]; then
      log_warn "pyyaml not installed — skipping mkdocs.yml key validation (install: pip install pyyaml)"
    elif echo "$result" | grep -q "MISSING_KEYS"; then
      log_err "mkdocs.yml: $result"
    else
      log_warn "mkdocs.yml validation had unexpected output: $result"
    fi
  else
    log_warn "python3 not found — skipping mkdocs.yml YAML validation"
  fi
else
  log_err "mkdocs.yml not found"
fi
echo ""

# ── 6. Internal link spot check ──────────────────────────────────────────────
echo "--- Internal link spot check ---"
broken_links=0
while IFS= read -r mdfile; do
  relfile="${mdfile#"$ROOT/"}"
  dir=$(dirname "$mdfile")

  while IFS= read -r link; do
    # Skip external links, anchors-only, and mailto
    [[ "$link" =~ ^https?:// ]] && continue
    [[ "$link" =~ ^mailto: ]] && continue
    [[ "$link" =~ ^# ]] && continue
    [[ -z "$link" ]] && continue

    target="${link%%#*}"  # strip anchor
    [[ -z "$target" ]] && continue

    resolved="${dir}/${target}"
    # Normalize (realpath --no-symlinks is Linux-only; use -m or fallback)
    if ! resolved_abs=$(realpath -m "$resolved" 2>/dev/null); then
      # macOS fallback: use python3 for path normalization
      resolved_abs=$(python3 -c "import os,sys; print(os.path.normpath(sys.argv[1]))" "$resolved" 2>/dev/null || echo "$resolved")
    fi

    if [[ ! -e "$resolved_abs" ]]; then
      log_warn "Possibly broken link in $relfile: $link"
      broken_links=$((broken_links + 1))
    fi
  done < <(grep -oE '\]\([^)]+\)' "$mdfile" 2>/dev/null | sed 's/^](//;s/)$//' || true)
done < <(find "$ROOT/docs" -name "*.md" 2>/dev/null)

if [[ "$broken_links" -eq 0 ]]; then
  log_ok "No broken internal links detected"
fi
echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo "=== Summary ==="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [[ "$ERRORS" -gt 0 ]]; then
  echo "docs-validate: FAIL (${ERRORS} error(s))"
  exit 1
else
  echo "docs-validate: PASS"
  exit 0
fi
