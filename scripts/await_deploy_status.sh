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

    # Check if the status is in a finished state or if we have reached the timeout limit
    if [[ "$STATUS" == "built" || "$STATUS" == "failed" || "$STATUS" == "cancelled" || $(( $(date +%s) - START_TIME )) -gt $TIMEOUT ]]; then
        log-info "$(date): Build has entered a finished state: $STATUS"
        break
    fi
    
    # If build
    if [ "$STATUS" == "failed" ]; then
        log-fail "$(date): Application build failed. Refer to the app manager for logs and additional information."
    fi

    # Sleep for a few seconds before the next iteration
    sleep 5
done