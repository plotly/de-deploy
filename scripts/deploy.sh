#!/usr/bin/env bash
[[ -n "$TRACE" ]] && set -x
set -eo pipefail

readonly SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly APPS_DIR_RELATIVE="${APPS_DIR_RELATIVE:-/}"
readonly APPS_DIR="${APPS_DIR:-${SOURCE_DIR}${APPS_DIR_RELATIVE}}"
readonly DE_HOST="${DE_HOST}"
readonly CREATE_APP="${CREATE_APP:-false}"

log-header() {
  declare desc="Log header formatter";
  echo "====> $*"
}

log-info() {
  declare desc="Log info formatter";
  echo "      $*"
}

log-warn() {
  declare desc="Log warn formatter";
  echo " ?    $*" 1>&2
}

log-fail() {
  declare desc="Log fail formatter";
  echo " !    $*" 1>&2
  exit 1
}

log-exit() {
  declare desc="Log exit formatter";
  echo " !    $*" 1>&2
  exit 0
}

fn-check-env() {
  declare APP="$1"

  if grep -Fxq "$APP" "$SOURCE_DIR/.deployignore"; then
    log-exit "App $APP is in the .deployignore file, skipping deploy"
  fi

  if [[ -z "$DE_USERNAME" ]]; then
    log-fail "DE_USERNAME is not defined"
  fi

  if [[ -z "$DE_HOST" ]]; then
    log-fail "DE_HOST is not defined"
  fi

  if [[ -z "$DE_PASSWORD" ]]; then
    log-fail "DE_PASSWORD is not defined"
  fi

  if [[ -z "$GITHUB_SHA" ]]; then
    log-fail "GITHUB_SHA is not defined"
  fi
}

main() {
  declare APP="$1"
  local app_dir="$APPS_DIR"
  local with_alias="$APP$deploy_alias"
  local remote_url="https://$DE_HOST/GIT/$with_alias"
  local app_created=false
  local force_push=true
  local push_code=false
  local exit_code remote_sha

  fn-check-env "$APP"

  # Check whether any files in app directory have been changed in most recent commit
  changed_files="$(git diff --name-only HEAD HEAD~1)"
  changed_dirs="$(cut -d/ -f1 <<< "$changed_files" | sort -u)"
  if grep -Fxq "$APP" <<< "$changed_dirs" ; then
    push_code=true
  else
    push_code=false
  fi

  if [[ $with_alias == *-demos ]]; then
    if [[ "$push_code" != "true" ]]; then
      push_code=$(APP=$with_alias METHOD="PUSH" python $ACTION_PATH/manage_apps.py)
    fi
  fi

  if [[ "$push_code" != "true" ]]; then
    log-header "🤜 App exists and is not updated in latest commit, skipping deploy"
    log-info "Check app out at https://$DE_HOST/$with_alias/"
    return 0
  fi

  log-header "Deploying $with_alias"  
  
  APP=$with_alias METHOD="CREATE" python $ACTION_PATH/manage_apps.py

  # Disable sslverification
  git config --global http.sslVerify false

  pushd "$app_dir" >/dev/null
  git init -q
  git remote rm origin 2>/dev/null || true
  git remote add "plotly" "$remote_url"
  git add .
  git commit -qm "Deployed commit: $GITHUB_SHA"
  popd >/dev/null

  pushd "$app_dir" >/dev/null
  log-header "Deploying $with_alias via force push"
  git push --force plotly master
  rm -rf ".git" >/dev/null
  popd >/dev/null
}

main "$@"