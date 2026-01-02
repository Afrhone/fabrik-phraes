#!/usr/bin/env bash
set -euo pipefail

# Publish the fabrik/ subtree as a standalone public GitHub repo
# Requirements: gh CLI, git

ORG=${1:-}
REPO=${2:-}
DESC=${3:-"Fabrik microservice template (CI, Docker, Factory integration)"}

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install from https://cli.github.com/" >&2
  exit 1
fi

if [ -z "$ORG" ] || [ -z "$REPO" ]; then
  echo "Usage: $0 <org_or_user> <repo_name> [description]" >&2
  exit 1
fi

set -x

# Create the repo (public). If it already exists, this will fail harmlessly.
gh repo create "$ORG/$REPO" --public -y --description "$DESC" || true

# Build a subtree branch with contents of ./fabrik
git subtree split --prefix=fabrik -b fabrik-publish || true

# Push subtree branch to the new repo's main
git push -u "git@github.com:$ORG/$REPO.git" fabrik-publish:main

# Cleanup local branch
git branch -D fabrik-publish || true

set +x
echo "Published fabrik subtree to https://github.com/$ORG/$REPO"
