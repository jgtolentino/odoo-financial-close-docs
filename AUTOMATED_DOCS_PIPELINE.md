# Automated Documentation Pipeline

## Overview

**Purpose**: Automated pipeline that syncs IT audit & SoD deployment docs from the production droplet (`159.223.75.148`) to GitHub, which triggers MkDocs build and deployment to GitHub Pages.

**Flow**:
```
Droplet (/root/docs/IT_AUDIT_SOD_DEPLOYMENT.md)
   ↓ [sync script: scripts/sync_it_audit_docs.sh]
GitHub (odoo-financial-close-docs repo)
   ↓ [GitHub Actions: .github/workflows/docs.yml]
MkDocs Build (Material theme)
   ↓
GitHub Pages (https://jgtolentino.github.io/odoo-financial-close-docs/)
```

---

## Installation (Run on Droplet 159.223.75.148)

### Step 1: Clone Repo and Setup Script

```bash
# SSH into droplet
ssh root@159.223.75.148

# Clone repo (first time only)
cd /root
git clone git@github.com:jgtolentino/odoo-financial-close-docs.git

# Make sync script executable
chmod +x /root/odoo-financial-close-docs/scripts/sync_it_audit_docs.sh

# Create symlink for easy access
ln -sf /root/odoo-financial-close-docs/scripts/sync_it_audit_docs.sh /usr/local/bin/sync-docs
```

### Step 2: Verify SSH Keys for GitHub

```bash
# Check if SSH key exists
ls -la ~/.ssh/id_*.pub

# If not, generate new key
ssh-keygen -t ed25519 -C "root@odoo-erp-prod" -f ~/.ssh/id_ed25519 -N ""

# Add to GitHub (copy public key)
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: https://github.com/settings/keys

# Test GitHub connection
ssh -T git@github.com
# Should see: "Hi jgtolentino! You've successfully authenticated..."
```

### Step 3: Setup Cron for Automated Sync

```bash
# Edit crontab
crontab -e

# Add this line (runs daily at 1 AM)
0 1 * * * /usr/local/bin/sync-docs >> /var/log/sync_it_audit_docs.log 2>&1
```

### Step 4: Manual Test Run

```bash
# Run sync script manually
/usr/local/bin/sync-docs

# Check logs
tail -f /var/log/sync_it_audit_docs.log
```

---

## Usage

### Manual Sync (from Droplet)

```bash
# Run sync immediately
sync-docs

# Or run from repo
cd /root/odoo-financial-close-docs
bash scripts/sync_it_audit_docs.sh
```

### Automated Sync (Cron)

- **Schedule**: Daily at 1 AM (SGT timezone)
- **Trigger**: Any changes to `/root/docs/IT_AUDIT_SOD_DEPLOYMENT.md`
- **Actions**:
  1. Pull latest from GitHub
  2. Copy IT audit doc to `docs/it-controls/`
  3. Commit and push changes
  4. GitHub Actions builds MkDocs
  5. Deploys to GitHub Pages

### View Published Docs

**Live URL**: https://jgtolentino.github.io/odoo-financial-close-docs/

Navigate to **IT Controls & Audit** → **IT Audit & SoD Deployment**

---

## GitHub Actions Workflow

**File**: `.github/workflows/docs.yml`

**Triggers**:
- Push to `main` branch (when sync script commits)
- Manual workflow dispatch
- Changes to `docs/**` or `mkdocs.yml`

**Steps**:
1. Checkout repo
2. Setup Python 3.11
3. Install MkDocs + Material theme
4. Build site with `mkdocs build --strict`
5. Deploy to GitHub Pages (`gh-pages` branch)

**Build Time**: ~30 seconds
**Deployment Time**: ~1 minute

---

## Adding More Documents to Auto-Sync

### Example: Add Spectra PF SOD Recommendation Doc

**Step 1**: Create source doc on droplet

```bash
# Create new doc
cat > /root/docs/SPECTRA_PF_SOD_RECOMMENDATION.md << 'EOF'
# Spectra PF Segregation of Duties Recommendation

[Your content here]
EOF
```

**Step 2**: Update sync script

Edit `/root/odoo-financial-close-docs/scripts/sync_it_audit_docs.sh`:

```bash
# Add new source/destination pair
SRC_DOC_2="/root/docs/SPECTRA_PF_SOD_RECOMMENDATION.md"
DEST_DOC_2="${REPO_DIR}/docs/it-controls/spectra-pf-sod-recommendation.md"

# Add copy command in sync section
if [ -f "$SRC_DOC_2" ]; then
  cp "$SRC_DOC_2" "$DEST_DOC_2"
  echo "✅ Copied SPECTRA_PF_SOD_RECOMMENDATION.md"
fi

# Update git add
git add "$DEST_DOC" "$DEST_DOC_2"
```

**Step 3**: Update MkDocs nav

Edit `mkdocs.yml`:

```yaml
nav:
  - IT Controls & Audit:
      - IT Audit & SoD Deployment: it-controls/it-audit-sod-deployment.md
      - Spectra PF SoD Recommendation: it-controls/spectra-pf-sod-recommendation.md
```

---

## Troubleshooting

### Problem: Sync Script Fails with Git Permission Error

**Solution**:
```bash
# Verify SSH key added to GitHub
ssh -T git@github.com

# If fails, regenerate and add key
ssh-keygen -t ed25519 -C "root@odoo-erp-prod" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
# Add to: https://github.com/settings/keys
```

### Problem: MkDocs Build Fails

**Check GitHub Actions**:
1. Go to: https://github.com/jgtolentino/odoo-financial-close-docs/actions
2. Click latest workflow run
3. Check build logs for errors

**Common Issues**:
- Invalid YAML in `mkdocs.yml` → Fix syntax
- Missing markdown files → Check file paths
- Broken links → Update links in docs

### Problem: Cron Job Not Running

**Check cron status**:
```bash
# Verify crontab entry
crontab -l

# Check cron logs
grep CRON /var/log/syslog | tail -20

# Check sync script logs
tail -f /var/log/sync_it_audit_docs.log
```

**Permissions issue**:
```bash
# Make script executable
chmod +x /root/odoo-financial-close-docs/scripts/sync_it_audit_docs.sh
```

---

## Monitoring & Logs

### Droplet Logs

**Sync script logs**:
```bash
tail -f /var/log/sync_it_audit_docs.log
```

**Cron logs**:
```bash
grep "sync_it_audit_docs" /var/log/syslog
```

### GitHub Actions Logs

**URL**: https://github.com/jgtolentino/odoo-financial-close-docs/actions

**Check latest run**:
- Status badge on README
- Email notifications (if enabled)

### GitHub Pages Deployment

**URL**: https://jgtolentino.github.io/odoo-financial-close-docs/

**Check deployment**:
```bash
# From local machine
curl -s https://jgtolentino.github.io/odoo-financial-close-docs/ | grep -q "IT Audit"
echo $?  # Should return 0 if deployed successfully
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ Droplet: 159.223.75.148 (odoo-erp-prod)                    │
│                                                              │
│ /root/docs/IT_AUDIT_SOD_DEPLOYMENT.md                      │
│              ↓                                               │
│ /usr/local/bin/sync-docs (cron: daily 1 AM)               │
│              ↓                                               │
│ git commit + push to origin/main                           │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ GitHub: jgtolentino/odoo-financial-close-docs              │
│                                                              │
│ main branch: docs/it-controls/it-audit-sod-deployment.md   │
│              ↓                                               │
│ .github/workflows/docs.yml (auto-trigger on push)         │
│              ↓                                               │
│ mkdocs build --strict                                       │
│              ↓                                               │
│ peaceiris/actions-gh-pages@v4 (deploy to gh-pages)       │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ GitHub Pages: https://jgtolentino.github.io/...           │
│                                                              │
│ Static site served from gh-pages branch                     │
│ Material theme, search, navigation                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Benefits

✅ **Single Source of Truth**: Droplet docs = Production reality
✅ **Zero Manual Updates**: Cron handles sync automatically
✅ **Version Controlled**: All changes tracked in Git
✅ **Automated Deployment**: GitHub Actions builds and publishes
✅ **Professional Presentation**: Material theme, responsive, searchable
✅ **Audit Trail**: Git history shows who changed what and when

---

## Next Steps

1. **Install on droplet** (follow Step 1-4 above)
2. **Test manual sync** to verify SSH keys and permissions
3. **Enable cron job** for daily automated sync
4. **Verify GitHub Pages** deployment after first sync
5. **Add more docs** to sync pipeline as needed

---

## Support

**Issues**: https://github.com/jgtolentino/odoo-financial-close-docs/issues
**Maintainer**: Finance Director + IT Market Director

---

**Last Updated**: 2025-12-29
**Version**: 1.0
