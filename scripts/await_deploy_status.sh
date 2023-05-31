#!/usr/bin/env bash
[[ -n "$TRACE" ]] && set -x
set -eo pipefail

START_TIME=$(date +%s)
log-info() {
    declare desc="Log info formatter";
    echo "      $*"
}
log-fail() {
    declare desc="Log fail formatter";
    echo " !    $*" 1>&2
    exit 1
}

# Start an infinite loop
while true; do
    # Check the application status
    STATUS=$(APP=$APP_NAME METHOD="DEPLOY_STATUS" python $SCRIPTS_PATH/manage_apps.py)
    log-info "$(date): Application is $STATUS..."

    # If build fails, fail the CI
    if [[ "$STATUS" == "failed" || $(( $(date +%s) - START_TIME )) -gt $TIMEOUT]]; then
        log-fail "$(date): Application build failed or await timed out. Refer to the app manager for logs and additional information."
    fi

    # Check if the status is in a finished state or if we have reached the timeout limit
    if [[ "$STATUS" == "built" || "$STATUS" == "cancelled" ]]; then
        log-info "$(date): Build has entered a finished state: $STATUS"
        break
    fi
    

    # Sleep for a few seconds before the next iteration
    sleep 5
done