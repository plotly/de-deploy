# Dash Enteprise Deploy

This is a GitHub Action to deploy a Dash application to Dash Enterprise 5.

Under the hood, it uses https://github.com/plotly/dekn-cli-python :rocket:

## Usage

To use a GitHub action you can just reference it on your Workflow file
(for more info check [this article by Github](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow))

If you have your application code on Github, add and commit the following to `<your-app>/.github/workflows/deploy.yml` to get started. Make sure to set the required variables in the "Secrets and variables" for Actions in your repository settings.

```yml
name: 'Dash Enterprise Deploy'

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: 'Deploy to Dash Enterprise'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de-deploy@main
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
```

### Inputs

As most GitHub actions, this action requires and uses some inputs, that you define in
your workflow file.

The inputs this action uses are:

| Name | Required | Default | Description |
|:----:|:--------:|:-------:|:-----------:|
| `DE_HOST` | `true` | N/A | The hostname of the DE instance, e.g. `example.plotly.host`. |
| `DE_USERNAME` | `true` | N/A | The username to deploy under. This user will be the application owner (it is recommended to configure a service user for automated deploys, e.g. `bot`) |
| `DE_PASSWORD` | `true` | N/A | The password for the specified user. |
| `GH_ACCESS_TOKEN` | `true` | N/A | A [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for Github. Required to install `dekn-cli-python`. |
| `app_name` | `false` | Repository name | The slug name for the application on DE. |
| `app_directory` | `false` | `${{ github.workspace }}` | The directory of the application. This might be modified if you are using this Action to manage a monorepo. |
| `timeout` | `false` | `300` | The time (in seconds) to poll the app deploy status for completion before the Action is considered failed. For applications with long build times, this might be incremented. |



## Examples
This workflow can be used to stagger your deployments between a deploy preview on a per-PR basis, followed by deployment to pre-prod on merge to `main`, followed by deployment to prod on `release`. For projects with less emphasis on production, it is sufficient to have two workflows: First for staging with PRs, followed by deployment to production on merge to `main`. The examples could be adapted for either workflow.
### Deploy to production on release

> `app_name` is left unspecified and will revert to the repository name.

```yml
name: 'Dash Enterprise Deploy'

on:
  release:
    types: ['published']

jobs:
  deploy:
    name: 'Prod deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de-deploy@main
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
```


### Deploy to pre-production on merge to main
> Note that `app_name` is optional and may need to be changed.

```yml
name: 'Dash Enterprise Preprod Deploy'

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: 'Preprod deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de-deploy@main
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
          app_name: example-dash-app-preprod
```


### Preview deploy on pull request
This action will deploy branches as `https://${DE_HOST}/${APP_NAME}-${event_number}`, e.g. if you are deploying an app called `inventory-analytics` to `example.plotly.host` and your PR number is `15`, the deploy preview would be available at `https://example.plotly.host/inventory-analytics-15` and would be redeployed on every new commit to that PR.

This flow will also add a comment to the pull request with relevant links for various pages on Dash Enterprise.

Notice that this will run on `type` `closed`. This is because the Action will run garbage collection and remove the preview application when a PR is closed/merged to save resources on Dash Enterprise.

```yml
name: 'Dash Enterprise Preview Deploy'

on:
  pull_request:
    types: ['opened', 'edited', 'synchronize', 'closed']

jobs:
  deploy:
    name: 'Preview deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de-deploy@main
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
```

## Usage with a monorepo
This Action can be used with a monorepo by constructing a matrix of changed applications and passing that matrix to `de-deploy`.

Notice the `find_changed_apps` job, which will find all app names (i.e. directories) and filter by directories changed in the most recent commit which do not appear in a helperfile specifying apps to ignore on deploy (by default `.deployignore`.)

Each app name is then passed to `de-deploy` as a matrix.

```yml
name: Production deploy
on:
  push:
    branches:
      - main
jobs:
  find_changed_apps:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
    - uses: actions/checkout@v1
    - id: set-matrix
      run: |
        # Get the list of directories changed in the most recent commit
        changed_files="$(git diff --name-only HEAD HEAD~1 -- "$APPS_DIRECTORY")"
        # Create a list of changed directories (apps) and ignore hidden directories
        APPS="$(cut -d/ -f1 <<< "$changed_files" | grep -v '^\.' | sort -u)"

        # Remove any apps which are in the deploy ignore file
        [[ -f "$DEPLOYIGNORE" ]] && APPS=$(grep -vFf "$DEPLOYIGNORE" <<< "$APPS")

        # Convert to JSON (making sure to properly handle the case where there are no changed directories)
        if [ -z "$APPS" ]; then
            apps_matrix='{"app_name": []}'
        else
            apps_matrix=$(printf '{"app_name": %s}' "[$(printf '"%s",' $APPS)]")
        fi

        # Store JSON as step output for use as a matrix
        echo "::set-output name=matrix::$apps_matrix"
      env:
        APPS_DIRECTORY: ${{ github.workspace }}
        DEPLOYIGNORE: ".deployignore"
  deploy_changed_apps:
    needs: find_changed_apps
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{fromJson(needs.find_changed_apps.outputs.matrix)}}
    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de-deploy@main
        with:
          DE_HOST: ${{ secrets.DASH_ENTERPRISE_HOST }}
          DE_USERNAME: ${{ secrets.DASH_ENTERPRISE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DASH_ENTERPRISE_PASSWORD }}
          GH_ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}
          app_name: ${{ matrix.app_name }}
          app_directory: ./${{ matrix.app_name }}
```

A side effect to note is that if this is used with the pattern:
```yml
on:
  pull_request:
    types: ['opened', 'edited', 'synchronize', 'closed']
```

It will work properly (including garbage collection), but comments with links will overwrite each other.

It is also worth noting that because this only fetches apps which were changed, it will not force the deploy if an app does not exist on the server and has not been changed in the last repository commit. To force the deploy of all directories on every commit, `$APPS` might be defined as:
```bash
# Get the list of directories & trim trailing slashes
APPS=$(cd $APPS_DIRECTORY && ls -d */ | sed 's/\/$//' | sort -u)
```

Note this might have performance drawbacks and may only be reasonably to apply for commits to `main` rather than in pull requests.
