#!/usr/bin/env bash
# Helper: initialize Git LFS tracking for .vsix files
# Usage: ./setup-lfs.sh

set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Please install git first." >&2
  exit 1
fi

if ! git lfs version >/dev/null 2>&1; then
  echo "git-lfs not found or not functioning. Please install/repair git-lfs and re-run this script." >&2
  echo "On Debian/Ubuntu you can: sudo apt-get install git-lfs && git lfs install" >&2
  exit 1
fi

echo "Installing Git LFS hooks (git lfs install)..."
git lfs install

echo "Ensuring .gitattributes contains .vsix tracking"
if [ ! -f .gitattributes ]; then
  echo "*.vsix filter=lfs diff=lfs merge=lfs -text" > .gitattributes
  git add .gitattributes
  git commit -m "Add .gitattributes: track .vsix with Git LFS" || true
else
  if ! grep -q "*.vsix filter=lfs" .gitattributes; then
    echo "*.vsix filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
    git add .gitattributes
    git commit -m "Update .gitattributes: track .vsix with Git LFS" || true
  else
    echo ".gitattributes already configured for .vsix"
  fi
fi

echo "If your .vsix files were already committed without LFS, convert them with:"
echo "  git lfs migrate import --include=*.vsix"
echo "(This rewrites history — only run if you understand the consequences.)"

echo "Done."
