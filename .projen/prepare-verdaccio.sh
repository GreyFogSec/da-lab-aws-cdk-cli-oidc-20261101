#!/usr/bin/env bash
set -euo pipefail
mkdir -p .lab-evidence
jq -n '{baseline:true,oidc_requested:false}' > .lab-evidence/oidc-claims.json
