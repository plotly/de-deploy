#!/usr/bin/env bash
[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# If an app name is not provided, use the repository name as the app name
if [ -z "$APP_NAME" ]; then
    repository="$GITHUB_REPOSITORY"
    APP_NAME=${repository#*/}
fi
# Add the PR number as a suffix for deploy previews
if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
    sep="-"
    APP_NAME=$APP_NAME$sep$EVENT_NUMBER
fi

echo $APP_NAME