# semantic-pull-request

A GitHub Action that ensures that your PR title matches the Conventional Commits spec.

## Usage

```yaml
- uses: xpertss/semantic-pull-request@<ref>
  with:
    types: |-
      feat
      fix
      chore
    requireScope: false
```

## Inputs

| Input | Required | Default | Notes |
|---|---|---|---|
| `types` | no | `feat fix docs style refactor perf test build ci chore revert` | allowed commit types, one per line (or comma-separated) |
| `requireScope` | no | `false` | require a `(scope)` in the title |
| `scopes` | no | — | if set, only these scopes are allowed |
| `disallowScopes` | no | — | scopes that are always rejected |
| `pattern` | no | — | a custom regex that, when set, replaces the conventional-commit validation entirely |
| `ignoreLabels` | no | — | comma-separated labels; a PR carrying any of them is exempt |

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
