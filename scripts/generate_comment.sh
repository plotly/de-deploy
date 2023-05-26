#!/usr/bin/env bash
[[ -n "$TRACE" ]] && set -x
set -eo pipefail

echo "### <span aria-hidden="true">✅</span> *$APP_NAME* pushed to Dash Enterprise!" >> message.md
echo "|  Name | Link |" >> message.md
echo "|:-:|------------------------|" >> message.md
echo "|<span aria-hidden="true">🔨</span> Latest commit | $GITHUB_SHA |" >> message.md
echo "|<span aria-hidden="true">🔍</span> Latest deploy log | https://$DE_HOST/apps/$APP_NAME#logs |" >> message.md
echo "|<span aria-hidden="true">🏠</span> Manager | https://$DE_HOST/apps/$APP_NAME |" >> message.md
echo "|<span aria-hidden="true">😎</span> **Deploy Preview** | https://$DE_HOST/$APP_NAME |" >> message.md
echo "---" >> message.md
echo "" >> message.md
echo "Complete diffs of deployment: $GITHUB_SHA" >> message.md
echo "*Note: Application build may not be complete at the time of this notification.*" >> message.md
