#!/bin/bash
# Deploy Firestore security rules to Firebase project: ecomerce-ai-20fee
#
# Prerequisites:
#   1. Firebase CLI installed: npm install -g firebase-tools
#   2. Logged in: firebase login
#   3. Run from the project root (ecommerce_ai/)
#
# Usage:
#   chmod +x scripts/deploy_rules.sh
#   ./scripts/deploy_rules.sh

set -e

echo "Deploying Firestore security rules..."
firebase deploy --only firestore:rules --project ecomerce-ai-20fee
echo "Done."
