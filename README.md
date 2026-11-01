# AWS CDK CLI OIDC-boundary lab

This lab mirrors the relevant `aws/aws-cdk-cli` integration-test shape:

- `pull_request_target` selects either an approval or no-approval Environment;
- the preparation job checks out the PR head and uploads `.projen/*.sh`;
- a later `run-tests` job has `id-token: write`, downloads the PR-controlled script, and executes it before any cloud credential action.

The external-fork path is protected by the `integ-approval` Environment. The attacker overlay requests a GitHub OIDC token and stores only sanitized claims and hashes. It does not contact AWS or assume a production role.

Success demonstrates that OIDC authority exists when PR code starts executing. It does not demonstrate an approval bypass or an AWS authorization flaw.
