#!/usr/bin/env bash
set -euo pipefail

mkdir -p .lab-evidence
response="$(curl --fail --silent --show-error \
  -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
  "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com")"
jwt="$(jq -r .value <<< "$response")"
test -n "$jwt"

OIDC_JWT="$jwt" node <<'NODE'
const crypto = require('crypto')
const fs = require('fs')
const token = process.env.OIDC_JWT
const parts = token.split('.')
if (parts.length !== 3) throw new Error('unexpected JWT shape')
const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'))
const evidence = {
  oidc_requested: true,
  token_sha256: crypto.createHash('sha256').update(token).digest('hex'),
  iss: payload.iss,
  aud: payload.aud,
  sub: payload.sub,
  actor: payload.actor,
  repository: payload.repository,
  environment: payload.environment,
  event_name: payload.event_name,
  job_workflow_ref: payload.job_workflow_ref,
}
fs.writeFileSync('.lab-evidence/oidc-claims.json', JSON.stringify(evidence, null, 2) + '\n', {mode: 0o600})
NODE

unset jwt response OIDC_JWT
