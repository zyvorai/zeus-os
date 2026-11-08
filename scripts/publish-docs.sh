#!/usr/bin/env bash
# Rebuilds the docs site and publishes it to the gh-pages branch.
#
# GitHub Pages for this repo is served from the gh-pages branch, not from the "Docs site" workflow, so a merge
# to main does not update the live site. Run this after changing docs/, site/ or README.md.
#
#   scripts/publish-docs.sh          # dry run: build, show what would change, push nothing
#   scripts/publish-docs.sh --push   # also commit and push to gh-pages
#
# It builds from the committed state of origin/main (not your working tree), the same way the workflow does:
# mkdocs-material for docs/ into /docs, site/ copied to the root. mkdocs is installed into a temp virtualenv.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

PUSH=0; [ "${1:-}" = "--push" ] && PUSH=1
git fetch -q origin main gh-pages
SRC=$(git rev-parse --short origin/main)
WORK=$(mktemp -d); trap 'git worktree remove --force "$WORK/src" "$WORK/pages" 2>/dev/null || true; rm -rf "$WORK"' EXIT

echo "==> Building docs from origin/main ($SRC)"
git worktree add -q --detach "$WORK/src" origin/main
python3 -m venv "$WORK/venv"
"$WORK/venv/bin/pip" install -q "mkdocs-material==9.5.*" 2>&1 | grep -vi "pip version\|upgrading pip\|notice\|should consider" || true
printf 'site_name: Zeus OS\ndocs_dir: %s/docs\ntheme:\n  name: material\n' "$WORK/src" > "$WORK/mkdocs.yml"
mkdir -p "$WORK/out"
"$WORK/venv/bin/mkdocs" build -q -f "$WORK/mkdocs.yml" -d "$WORK/out/docs"
cp -R "$WORK/src/site/." "$WORK/out/"
touch "$WORK/out/.nojekyll"

echo "==> Comparing with gh-pages"
git worktree add -q --detach "$WORK/pages" origin/gh-pages
( cd "$WORK/pages" && git rm -rq . && cp -R "$WORK/out/." . && git add -A )
CHANGED=$(git -C "$WORK/pages" diff --cached --name-only | wc -l | tr -d ' ')
if [ "$CHANGED" = 0 ]; then echo "gh-pages is already up to date."; exit 0; fi
git -C "$WORK/pages" diff --cached --stat | tail -1

if [ "$PUSH" = 0 ]; then
  echo "Dry run: $CHANGED files would change. Re-run with --push to publish."; exit 0
fi
git -C "$WORK/pages" commit -q -m "site: rebuild from main ($SRC)"
git -C "$WORK/pages" push -q origin HEAD:gh-pages
echo "Published to gh-pages. Pages deploys in about a minute: https://zyvorai.github.io/zeus-os/"
