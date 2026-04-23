#!/bin/bash

##############################################################################
# Verify Branch Protection Rules
##############################################################################

OWNER="valensniyonkuru"
REPO="project_v2_branch_protection"

echo "=========================================="
echo "Branch Protection Verification"
echo "Repository: ${OWNER}/${REPO}"
echo "=========================================="
echo ""

for branch in develop staging main; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Branch: ${branch}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    gh api repos/${OWNER}/${REPO}/branches/${branch}/protection --jq '
        "Required Reviewers: " + (.required_pull_request_reviews.required_approving_review_count | tostring),
        "Dismiss Stale Reviews: " + (.required_pull_request_reviews.dismiss_stale_reviews | tostring),
        "Up-to-date Required: " + (.required_status_checks.strict | tostring),
        "Force Pushes Allowed: " + (.allow_force_pushes.enabled | tostring),
        "Deletions Allowed: " + (.allow_deletions.enabled | tostring),
        "Conversation Resolution: " + (.required_conversation_resolution.enabled | tostring)
    '
    
    echo ""
done

echo "=========================================="
echo "✅ Verification Complete"
echo "=========================================="
