#!/usr/bin/env bash
set -euo pipefail

# =========================================================================
# Automated IT Audit Docs Sync Script
# =========================================================================
# Purpose: Sync IT audit & SoD deployment docs from droplet to GitHub
# Trigger: Cron (daily at 1 AM) or manual execution
# Repo: odoo-financial-close-docs
# =========================================================================

REPO_DIR="/root/odoo-financial-close-docs"
SRC_DOC="/root/docs/IT_AUDIT_SOD_DEPLOYMENT.md"
DEST_DOC="${REPO_DIR}/docs/it-controls/it-audit-sod-deployment.md"
GIT_REMOTE="git@github.com:jgtolentino/odoo-financial-close-docs.git"
GIT_BRANCH="main"

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Starting IT audit docs sync..."

# Step 1: Clone repo if first time, otherwise pull latest
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "Cloning repo for first time..."
  git clone "$GIT_REMOTE" "$REPO_DIR"
else
  echo "Pulling latest changes from GitHub..."
  cd "$REPO_DIR"
  git fetch origin "$GIT_BRANCH"
  git reset --hard "origin/$GIT_BRANCH"
fi

cd "$REPO_DIR"

# Step 2: Sync IT audit doc from source to repo
echo "Syncing IT audit doc..."
mkdir -p "$(dirname "$DEST_DOC")"

if [ -f "$SRC_DOC" ]; then
  cp "$SRC_DOC" "$DEST_DOC"
  echo "✅ Copied $SRC_DOC to $DEST_DOC"
else
  echo "⚠️ Source doc $SRC_DOC not found. Creating placeholder..."
  cat > "$DEST_DOC" <<'EOF'
# IT Audit & SoD Deployment

**Status**: Awaiting source document from droplet `/root/docs/IT_AUDIT_SOD_DEPLOYMENT.md`

This file will be auto-synced once the source document is available.
EOF
fi

# Step 3: Check for changes
if git diff --quiet; then
  echo "✅ No changes detected. Exiting."
  exit 0
fi

# Step 4: Commit and push changes
echo "Committing changes..."
git add "$DEST_DOC"
git commit -m "chore(docs): sync IT audit & SoD deployment from server

Auto-synced from droplet:/root/docs/IT_AUDIT_SOD_DEPLOYMENT.md
Timestamp: $(date +%Y-%m-%d\ %H:%M:%S)
"

echo "Pushing to GitHub..."
git push origin "$GIT_BRANCH"

echo "✅ Successfully synced and pushed IT audit docs!"
echo "🚀 GitHub Actions will build MkDocs and deploy to GitHub Pages"
echo "📖 View at: https://jgtolentino.github.io/odoo-financial-close-docs/"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Sync complete."
