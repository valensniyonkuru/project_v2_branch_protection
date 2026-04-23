#!/bin/bash

##############################################################################
# GitHub Branch Protection Rules Setup Script
# 
# This script configures branch protection rules for the repository:
# - valensniyonkuru/project_v2_branch_protection
#
# Branches configured:
#   - develop:  1 reviewer
#   - staging:  1 reviewer + up-to-date required
#   - main:     2 reviewers + up-to-date required + conversation resolution
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Sufficient permissions to manage branch protection
#
##############################################################################

set -e

# Configuration
OWNER="valensniyonkuru"
REPO="project_v2_branch_protection"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

##############################################################################
# Function to apply branch protection rules
# Args: branch_name, required_reviewers, require_up_to_date, require_conversation_resolution
##############################################################################
apply_protection() {
    local branch=$1
    local reviewers=$2
    local require_up_to_date=$3
    local require_conversation_resolution=$4
    
    print_status "Applying protection rules to branch: ${branch}"
    
    # Create temporary JSON file for API payload
    local temp_file=$(mktemp)
    
    # Build required_status_checks
    local status_checks="null"
    if [ "$require_up_to_date" = "true" ]; then
        status_checks='{"strict":true,"contexts":[]}'
    fi
    
    # Build the JSON payload
    cat > "$temp_file" <<EOF
{
  "required_pull_request_reviews": {
    "required_approving_review_count": ${reviewers},
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  },
  "enforce_admins": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_status_checks": ${status_checks},
  "require_conversation_resolution": ${require_conversation_resolution},
  "restrictions": null
}
EOF
    
    # Apply the protection rule via GitHub API
    if gh api repos/${OWNER}/${REPO}/branches/${branch}/protection \
        -X PUT --input "$temp_file" > /dev/null 2>&1; then
        print_success "Branch protection applied to: ${branch}"
    else
        print_error "Failed to apply protection to: ${branch}"
        print_error "API Response:"
        gh api repos/${OWNER}/${REPO}/branches/${branch}/protection \
            -X PUT --input "$temp_file" 2>&1 | head -20
        rm -f "$temp_file"
        return 1
    fi
    
    rm -f "$temp_file"
}

##############################################################################
# Main Script
##############################################################################

echo "=========================================="
echo "GitHub Branch Protection Rules Setup"
echo "Repository: ${OWNER}/${REPO}"
echo "=========================================="
echo ""

# Verify gh CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

# Verify user is authenticated
if ! gh auth status > /dev/null 2>&1; then
    print_error "GitHub CLI is not authenticated. Please run: gh auth login"
    exit 1
fi

print_status "GitHub CLI is authenticated"
echo ""

# Apply protection rules to each branch
print_status "Starting branch protection setup..."
echo ""

# Develop branch: 1 reviewer, no up-to-date requirement
print_status "Configuring 'develop' branch..."
apply_protection "develop" "1" "false" "false"
echo ""

# Staging branch: 1 reviewer, require up-to-date
print_status "Configuring 'staging' branch..."
apply_protection "staging" "1" "true" "false"
echo ""

# Main branch: 2 reviewers, require up-to-date, require conversation resolution
print_status "Configuring 'main' branch..."
apply_protection "main" "2" "true" "true"
echo ""

# Summary
echo "=========================================="
print_success "All branch protection rules have been applied!"
echo "=========================================="
echo ""
echo "Summary of applied rules:"
echo "  - develop:  1 reviewer"
echo "  - staging:  1 reviewer + up-to-date required"
echo "  - main:     2 reviewers + up-to-date required + conversation resolution"
echo ""
echo "Additional settings for all branches:"
echo "  - Dismiss stale reviews: YES"
echo "  - Allow force pushes: NO"
echo "  - Allow deletions: NO"
echo ""
