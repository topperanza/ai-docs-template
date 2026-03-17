#!/usr/bin/env bash
# docs-export-pdf.sh
# Best-effort PDF export of the docs/ directory using pandoc.
#
# Requirements:
#   - pandoc (https://pandoc.org/installing.html)
#   - A LaTeX distribution for PDF output, e.g.:
#       macOS: brew install basictex  or  brew install --cask mactex
#       Ubuntu: apt-get install texlive-xetex
#   - Or use a Docker-based pandoc for a hermetic build
#
# If pandoc or LaTeX is unavailable the script exits 0 (non-blocking).
# CI treats this as best-effort; failures do not block publishing.
#
# Output: docs-export-<DATESTAMP>.pdf in the current directory.
set -uo pipefail

DATESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT="docs-export-${DATESTAMP}.pdf"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$ROOT/docs"

echo "=== docs-export-pdf.sh ==="
echo "Date: $DATESTAMP"
echo "Output: $OUTPUT"
echo ""

# ── Dependency check ─────────────────────────────────────────────────────────
if ! command -v pandoc &>/dev/null; then
  echo "SKIP: pandoc not found. Install pandoc to enable PDF export."
  echo "  macOS:  brew install pandoc && brew install --cask basictex"
  echo "  Ubuntu: apt-get install -y pandoc texlive-xetex"
  exit 0
fi

echo "pandoc version: $(pandoc --version | head -1)"

# Check for a PDF-capable LaTeX engine
PDF_ENGINE=""
for engine in xelatex pdflatex lualatex; do
  if command -v "$engine" &>/dev/null; then
    PDF_ENGINE="$engine"
    break
  fi
done

if [[ -z "$PDF_ENGINE" ]]; then
  echo "SKIP: No LaTeX PDF engine found (tried xelatex, pdflatex, lualatex)."
  echo "  Install one of: texlive-xetex, basictex, mactex"
  exit 0
fi

echo "PDF engine: $PDF_ENGINE"
echo ""

# ── Collect Markdown files ────────────────────────────────────────────────────
# Order: index.md first, then alphabetical
mapfile -t MD_FILES < <(
  find "$DOCS_DIR" -name "*.md" | sort | \
  awk '{ if ($0 ~ /\/index\.md$/) print "0 " $0; else print "1 " $0 }' | \
  sort | awk '{print $2}'
)

if [[ "${#MD_FILES[@]}" -eq 0 ]]; then
  echo "SKIP: No Markdown files found in $DOCS_DIR"
  exit 0
fi

echo "Files to export (${#MD_FILES[@]}):"
for f in "${MD_FILES[@]}"; do
  echo "  ${f#"$ROOT/"}"
done
echo ""

# ── Run pandoc ────────────────────────────────────────────────────────────────
echo "Running pandoc..."
cd "$ROOT"

pandoc \
  --from markdown \
  --to pdf \
  --pdf-engine="$PDF_ENGINE" \
  --toc \
  --toc-depth=3 \
  --variable geometry:margin=1in \
  --variable fontsize=11pt \
  --variable colorlinks=true \
  --output "$OUTPUT" \
  "${MD_FILES[@]}" \
  2>&1

if [[ $? -eq 0 ]]; then
  echo ""
  echo "PDF exported: $ROOT/$OUTPUT"
  echo "File size: $(du -h "$ROOT/$OUTPUT" | cut -f1)"
else
  echo ""
  echo "FAIL: pandoc exited with an error. PDF not created."
  echo "This is best-effort — check pandoc and LaTeX installation."
  exit 1
fi
