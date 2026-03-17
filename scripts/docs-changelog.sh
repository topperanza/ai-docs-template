#!/usr/bin/env bash
# docs-changelog.sh
# Extracts and formats changelog entries from CHANGELOG.md.
#
# Usage:
#   bash scripts/docs-changelog.sh              # print all entries
#   bash scripts/docs-changelog.sh --unreleased # print only [Unreleased] section
#   bash scripts/docs-changelog.sh --latest     # print only the most recent release
#   bash scripts/docs-changelog.sh --version 2026.03-1  # print a specific version
#
# Output goes to stdout. Redirect to a file as needed:
#   bash scripts/docs-changelog.sh --latest > release-notes.txt
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGELOG="$ROOT/CHANGELOG.md"
MODE="${1:-all}"
VERSION_FILTER="${2:-}"

# ── Validate ──────────────────────────────────────────────────────────────────
if [[ ! -f "$CHANGELOG" ]]; then
  echo "ERROR: CHANGELOG.md not found at $CHANGELOG" >&2
  exit 1
fi

# ── Helper: extract a section by heading ─────────────────────────────────────
# Prints lines from a matching "## [...]" heading up to (not including) the next
# "## " heading at the same level.
extract_section() {
  local pattern="$1"
  local in_section=0

  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]] ]]; then
      if [[ "$in_section" -eq 1 ]]; then
        # Hit next section — stop
        break
      fi
      if echo "$line" | grep -qiF "$pattern"; then
        in_section=1
        echo "$line"
        continue
      fi
    fi
    if [[ "$in_section" -eq 1 ]]; then
      echo "$line"
    fi
  done < "$CHANGELOG"
}

# ── Helper: get the first released version heading ───────────────────────────
get_latest_version() {
  # Use sed for portability (macOS grep lacks -P/PCRE)
  grep -E '^\#\# \[' "$CHANGELOG" \
    | sed 's/^## \[//' | sed 's/\].*//' \
    | grep -iv 'unreleased' \
    | head -1
}

# ── Mode dispatch ─────────────────────────────────────────────────────────────
case "$MODE" in
  --unreleased)
    echo "=== [Unreleased] ==="
    result=$(extract_section "[Unreleased]")
    if [[ -z "$result" ]] || ! echo "$result" | grep -qvE '^\s*$'; then
      echo "(No unreleased changes)"
    else
      echo "$result"
    fi
    ;;

  --latest)
    latest=$(get_latest_version)
    if [[ -z "$latest" ]]; then
      echo "No released versions found in CHANGELOG.md" >&2
      exit 1
    fi
    echo "=== Latest release: [$latest] ==="
    extract_section "[$latest]"
    ;;

  --version)
    if [[ -z "$VERSION_FILTER" ]]; then
      echo "Usage: $0 --version <version-string>" >&2
      exit 1
    fi
    echo "=== Version: [$VERSION_FILTER] ==="
    result=$(extract_section "[$VERSION_FILTER]")
    if [[ -z "$result" ]]; then
      echo "Version [$VERSION_FILTER] not found in CHANGELOG.md" >&2
      exit 1
    fi
    echo "$result"
    ;;

  all|--all)
    echo "=== Full Changelog ==="
    echo ""
    cat "$CHANGELOG"
    ;;

  --summary)
    # Print a compact one-line summary of each release
    echo "=== Changelog Summary ==="
    grep -E '^\#\# \[' "$CHANGELOG" | while IFS= read -r line; do
      # Extract version: text between first [ and ]
      version=$(echo "$line" | sed 's/^## \[//' | sed 's/\].*//')
      # Extract date: YYYY-MM-DD pattern
      date_str=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)
      if [[ -n "$date_str" ]]; then
        echo "  $version  ($date_str)"
      else
        echo "  $version"
      fi
    done
    ;;

  --help|-h)
    echo "Usage: $0 [MODE] [VERSION]"
    echo ""
    echo "Modes:"
    echo "  (none)         Print full CHANGELOG.md"
    echo "  --unreleased   Print only the [Unreleased] section"
    echo "  --latest       Print the most recent released version"
    echo "  --version VER  Print a specific version section"
    echo "  --summary      Print a compact list of all versions"
    echo "  --help         Show this help"
    ;;

  *)
    echo "Unknown mode: $MODE. Run '$0 --help' for usage." >&2
    exit 1
    ;;
esac
