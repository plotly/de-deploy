APPS=$(ls -d */ | sort -u)
changed_files="$(git diff --name-only HEAD HEAD~1)"
changed_dirs="$(cut -d/ -f1 <<< "$changed_files" | sort -u)"

message=""

for APP in $APPS
do
APP=${APP%?}
if grep -Fxq "$APP" <<< "$changed_dirs" ; then
    echo "### <span aria-hidden="true">✅</span> *$APP-$EVENT_NUMBER* pushed to Dash Enterprise!" >> message.md
    echo "|  Name | Link |" >> message.md
    echo "|:-:|------------------------|" >> message.md
    echo "|<span aria-hidden="true">🔨</span> Latest commit | ${{github.sha}} |" >> message.md
    echo "|<span aria-hidden="true">🔍</span> Latest deploy log | https://$DE_HOST/apps/$APP-$EVENT_NUMBER#logs |" >> message.md
    echo "|<span aria-hidden="true">🏠</span> Manager | https://$DE_HOST/apps/$APP-$EVENT_NUMBER |" >> message.md
    echo "|<span aria-hidden="true">😎</span> **Deploy Preview** | https://$DE_HOST/$APP-$EVENT_NUMBER |" >> message.md
    echo "---" >> message.md
    message="TRUE"
fi
done
if ! [ -z "$message" ]
then
    echo "" >> message.md
    echo "Complete diffs of deployment: $GITHUB_SHA" >> message.md
    echo "*Note: Application build may not be complete at the time of this notification.*" >> message.md
else
    echo "No applications deployed as part of this PR." >> message.md
fi