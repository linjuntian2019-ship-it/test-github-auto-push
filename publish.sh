#!/bin/bash

set -e

REPO_NAME="test-github-auto-push"

echo "Checking GitHub login..."
gh auth status

echo "Initializing git repository..."
if [ ! -d ".git" ]; then
  git init
fi

echo "Creating .gitignore..."
cat > .gitignore <<'GITIGNORE'
.env
venv/
__pycache__/
.DS_Store
output/
state.json
GITIGNORE

echo "Adding files..."
git add .

echo "Creating commit..."
git commit -m "Initial commit" || echo "Nothing new to commit."

echo "Creating GitHub repo and pushing..."
gh repo create "$REPO_NAME" --public --source=. --remote=origin --push

echo "Done."
echo "Your repository should now be on GitHub:"
gh repo view --web
