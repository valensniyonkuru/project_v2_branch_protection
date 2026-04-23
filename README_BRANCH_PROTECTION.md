# Branch Protection Rules Setup

This directory contains a bash script to configure GitHub branch protection rules for the `project_v2_branch_protection` repository using Infrastructure as Code.

## Prerequisites

Before running the script, ensure you have:

1. **GitHub CLI (gh)** installed
   - Download: https://github.com/cli/cli
   - Or install via package manager:
     ```bash
     # macOS
     brew install gh
     
     # Ubuntu/Debian
     sudo apt-get install gh
     
     # Windows (using WSL)
     curl -fsSLo /usr/share/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg
     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages focal main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
     sudo apt update
     sudo apt install gh
     ```

2. **GitHub CLI Authentication**
   - Authenticate your GitHub account:
     ```bash
     gh auth login
     ```
   - Select: HTTPS, GitHub.com, and paste your personal access token or follow the web login

3. **Sufficient Permissions**
   - You need admin access to the repository to manage branch protection rules

## Usage

### Step 1: Make the script executable

```bash
chmod +x branch_protection.sh
```

### Step 2: Run the script

```bash
./branch_protection.sh
```

### Step 3: Verify the rules were applied

You can verify the protection rules in your GitHub repository by:
1. Going to your repository: https://github.com/valensniyonkuru/project_v2_branch_protection
2. Navigate to **Settings** → **Branches**
3. Check each branch under "Branch protection rules"

## What This Script Does

The script applies the following branch protection rules:

### `develop` branch
- ✅ Require a pull request before merging
- ✅ Require **1 reviewer** to approve PR
- ✅ Dismiss stale reviews when new commits are pushed
- ✅ No force pushes allowed
- ✅ No deletions allowed

### `staging` branch
- ✅ Require a pull request before merging
- ✅ Require **1 reviewer** to approve PR
- ✅ Dismiss stale reviews when new commits are pushed
- ✅ Require branch to be up to date before merging
- ✅ No force pushes allowed
- ✅ No deletions allowed

### `main` branch
- ✅ Require a pull request before merging
- ✅ Require **2 reviewers** to approve PR
- ✅ Dismiss stale reviews when new commits are pushed
- ✅ Require branch to be up to date before merging
- ✅ Require conversation resolution before merging
- ✅ No force pushes allowed
- ✅ No deletions allowed

## Idempotency

The script is **idempotent**, which means:
- You can run it multiple times without issues
- It will overwrite existing rules with the new configuration
- It's safe to run as part of CI/CD pipelines

## Troubleshooting

### Error: "GitHub CLI is not installed"
- Install GitHub CLI from https://github.com/cli/cli
- Run `gh --version` to verify installation

### Error: "GitHub CLI is not authenticated"
- Run `gh auth login` to authenticate
- Select HTTPS as the protocol
- Use a personal access token with `repo` and `admin:repo_hook` scopes

### Error: "Failed to apply protection"
- Verify you have admin access to the repository
- Check that the branch exists: `gh api repos/valensniyonkuru/project_v2_branch_protection/branches`
- Ensure your personal access token has sufficient permissions

## API Endpoint

The script uses the GitHub REST API endpoint:
```
PUT /repos/{owner}/{repo}/branches/{branch}/protection
```

For more details, see the GitHub API documentation:
https://docs.github.com/en/rest/reference/repos#update-branch-protection

## Manual Verification

To manually check the protection rules via CLI:

```bash
# Check develop branch protection
gh api repos/valensniyonkuru/project_v2_branch_protection/branches/develop/protection

# Check staging branch protection
gh api repos/valensniyonkuru/project_v2_branch_protection/branches/staging/protection

# Check main branch protection
gh api repos/valensniyonkuru/project_v2_branch_protection/branches/main/protection
```

## Reverting Changes

To remove all branch protection rules, you can run:

```bash
gh api repos/valensniyonkuru/project_v2_branch_protection/branches/develop/protection -X DELETE
gh api repos/valensniyonkuru/project_v2_branch_protection/branches/staging/protection -X DELETE
gh api repos/valensniyonkuru/project_v2_branch_protection/branches/main/protection -X DELETE
```

## Support

For issues or questions:
1. Check GitHub CLI documentation: https://cli.github.com/manual
2. Review GitHub API docs: https://docs.github.com/en/rest
3. Check repository settings: https://github.com/valensniyonkuru/project_v2_branch_protection/settings/branches
