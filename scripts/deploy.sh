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

  log-header "Deploying $with_alias"  
  
  APP=$with_alias METHOD="CREATE" python $SCRIPTS_PATH/manage_apps.py

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