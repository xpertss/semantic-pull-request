#!/usr/bin/env bash
set -euo pipefail

title="${PR_TITLE:-}"
labels="${PR_LABELS:-}"

types_input="${INPUT_TYPES:-feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert}"
require_scope="${INPUT_REQUIRESCOPE:-false}"
scopes_input="${INPUT_SCOPES:-}"
disallow_scopes_input="${INPUT_DISALLOWSCOPES:-}"
pattern_input="${INPUT_PATTERN:-}"
ignore_labels_input="${INPUT_IGNORELABELS:-}"

# split on commas and newlines, trim whitespace, drop empty entries
split_list() {
  local input="$1"
  local line
  while IFS= read -r line; do
    line="$(echo "$line" | xargs)"
    [[ -n "$line" ]] && echo "$line"
  done < <(printf '%s\n' "$input" | tr ',' '\n')
}

# No PR title (e.g. a merge_group event) -> pass
if [[ -z "$title" ]]; then
  exit 0
fi

# Label-exempt short-circuit
if [[ -n "$ignore_labels_input" && -n "$labels" ]]; then
  mapfile -t ignore_labels < <(split_list "$ignore_labels_input")
  mapfile -t pr_labels < <(split_list "$labels")
  for pr_label in "${pr_labels[@]}"; do
    for ignore_label in "${ignore_labels[@]}"; do
      if [[ "$pr_label" == "$ignore_label" ]]; then
        exit 0
      fi
    done
  done
fi

# Custom pattern replaces conventional-commit validation entirely
if [[ -n "$pattern_input" ]]; then
  if [[ "$title" =~ $pattern_input ]]; then
    exit 0
  fi
  echo "::error::PR title \"${title}\" does not match the required pattern: ${pattern_input}"
  exit 1
fi

mapfile -t types < <(split_list "$types_input")
if [[ ${#types[@]} -eq 0 ]]; then
  echo "::error::No allowed commit types configured"
  exit 1
fi
types_alt="$(IFS='|'; echo "${types[*]}")"

if [[ "$require_scope" == "true" ]]; then
  regex="^(${types_alt})\\(([^()]+)\\): .+"
else
  regex="^(${types_alt})(\\(([^()]+)\\))?: .+"
fi

if [[ ! "$title" =~ $regex ]]; then
  echo "::error::PR title \"${title}\" does not match Conventional Commits format. Expected: <type>(<scope>): <subject> where <type> is one of: ${types[*]}"
  exit 1
fi

if [[ "$require_scope" == "true" ]]; then
  scope_match="${BASH_REMATCH[2]:-}"
else
  scope_match="${BASH_REMATCH[3]:-}"
fi

if [[ -n "$scope_match" && -n "$scopes_input" ]]; then
  mapfile -t allowed_scopes < <(split_list "$scopes_input")
  allowed=false
  for scope in "${allowed_scopes[@]}"; do
    if [[ "$scope" == "$scope_match" ]]; then
      allowed=true
      break
    fi
  done
  if [[ "$allowed" == false ]]; then
    echo "::error::PR title scope \"${scope_match}\" is not in the allowed scopes list: ${allowed_scopes[*]}"
    exit 1
  fi
fi

if [[ -n "$scope_match" && -n "$disallow_scopes_input" ]]; then
  mapfile -t denied_scopes < <(split_list "$disallow_scopes_input")
  for scope in "${denied_scopes[@]}"; do
    if [[ "$scope" == "$scope_match" ]]; then
      echo "::error::PR title scope \"${scope_match}\" is not allowed"
      exit 1
    fi
  done
fi

exit 0
