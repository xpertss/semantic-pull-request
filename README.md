# semantic-pull-request

A GitHub Action that ensures that your PR title matches the Conventional
Commits spec. A first-party, network-free replacement for
[amannn/action-semantic-pull-request](https://github.com/amannn/action-semantic-pull-request).

## Examples

**Valid PR titles:**

- `fix: Correct typo`
- `feat: Add support for Node.js 18`
- `feat(ui): Add Button component`

**Invalid PR titles:**

- `Added a new feature` — missing type
- `feature: Add new thing` — `feature` is not an allowed type
- `chore(deps): Bump foo` — rejected when `deps` is listed in `disallowScopes`

## Usage

```yaml
name: 'Lint PR'

on:
  pull_request_target:
    types: [opened, reopened, edited, synchronize]
  merge_group:

jobs:
  main:
    name: Validate PR title
    runs-on: ubuntu-latest
    steps:
      - uses: xpertss/semantic-pull-request@<ref>
        with:
          types: |-
            feat
            fix
            chore
          requireScope: false
```

No permissions are required — see [Permissions](#permissions).

### Event triggers

Two events can be used as triggers, each with different characteristics:

- `pull_request_target` — works for PRs opened from forks; always runs the
  workflow configuration from the base branch.
- `pull_request` — uses the configuration from the PR's head branch.

> If the check is required for merging, include `synchronize` in the trigger
> types so the check runs on every new push.

Events with no PR title (e.g. `merge_group`) pass without validation.

## Inputs

| Input | Required | Default | Notes |
|---|---|---|---|
| `types` | no | `feat fix docs style refactor perf test build ci chore revert` | allowed commit types, one per line (or comma-separated); entries are regex patterns, matched as an anchored alternation |
| `requireScope` | no | `false` | require a `(scope)` in the title |
| `scopes` | no | — | if set, only these scopes are allowed; one per line (or comma-separated), **exact match** (not regex) |
| `disallowScopes` | no | — | scopes that are always rejected; one per line (or comma-separated), **exact match** (not regex) |
| `pattern` | no | — | a custom regex that, when set, replaces the conventional-commit validation entirely |
| `ignoreLabels` | no | — | labels, one per line (or comma-separated); a PR carrying any of them is exempt |

On failure, the action emits a `::error::` annotation containing the
offending title and the expected format, and fails the step.

## Outputs

None. The action is a pure check: it passes (exit 0) or fails the step (exit 1).

## Permissions

None required. The action reads only the PR title (and labels) from the event
context and validates it locally.

## Network access

None. This action makes no network calls.

## Security

The PR title is always treated as an opaque string: it is matched against a
regex built only from the action's own (trusted) inputs, and is never
`eval`'d, interpolated into a shell command, or used to build one.


