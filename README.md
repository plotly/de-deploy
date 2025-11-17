# Dash Enteprise Deploy

This is a GitHub Action to deploy a Dash application to Dash Enterprise 5.

Under the hood, it uses `de-client` :rocket:

<div align="center">
  <a href="https://dash.plotly.com/project-maintenance">
    <img src="https://dash.plotly.com/assets/images/maintained-by-plotly.png" width="400px" alt="Maintained by Plotly">
  </a>
</div>


## Usage
If you have your application code on Github, add and commit the following to `<your-app>/.github/workflows/deploy.yml` to get started. Make sure to set the required variables in the "Secrets and variables" for Actions in your repository settings.

> Note: This is a minimal example. Review the table below for additional inputs and recommendations for using this Action with a monorepo.

```yml
name: 'Dash Enterprise Deploy'

on:
  push:
    branches: [main]
  pull_request:
    types: ['opened', 'edited', 'synchronize', 'closed']

jobs:
  deploy:
    name: 'Deploy to Dash Enterprise'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de-deploy # Add @ version/branch/commit to pin, e.g. plotly/de-deploy@v4 or plotly/de-deploy@main
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
```

### Inputs

As with most GitHub actions, this action requires and uses some inputs that you define in your workflow file.

The inputs this action uses are:

| Name | Required | Default | Description |
|:----:|:--------:|:-------:|:-----------:|
| `DE_HOST` | `true` | N/A | The hostname of the DE instance, e.g. `example.plotly.host`. |
| `DE_USERNAME` | `true` | N/A | The username to deploy under. This user will be the application owner (it is recommended to configure a service user for automated deploys, e.g. `bot`) |
| `DE_PASSWORD` | `true` | N/A | The password for the specified user. |
| `GH_ACCESS_TOKEN` | `true` | N/A | A [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for Github. Required to add app link as action output. Permissions should be set to `repo`. |
| `app_name` | `false` | Repository name | Name of the app to deploy. If not provided, the repository name will be used. |
| `app_directory` | `false` | `${{ github.workspace }}` | The directory of the application. This might be modified if you are using this Action to manage a monorepo. |
| `group_viewers` | `false` | None | User groups to add as viewers to the app. If not provided, no groups will be added. |
| `group_co_owners` | `false` | None | User groups to add as co-owners to the app. If not provided, no groups will be added. |
| `create_redis` | `false` | None | True to create a Redis instance for the app. |
| `create_postgres` | `false` | None | True to create a Postgres instance for the app. |
| `create_persistent_filesystem` | `false` | None | True to create a persistent filesystem for the app. |
| `de_client_version` | `false` | None | Version of the Dash Enterprise client to install. If not provided, the latest version will be installed. |

### Preview deploy on pull request
This action will deploy branches using the `on: pull_request: types: ['opened', 'edited', 'synchronize', 'closed']` trigger as `https://${DE_HOST}/${APP_NAME}-${event_number}`, e.g. if you are deploying an app called `inventory-analytics` to `example.plotly.host` and your PR number is `15`, the deploy preview would be available at `https://example.plotly.host/inventory-analytics-15` and would be redeployed on every new commit to that PR.

This flow will also add a link to the Action run with relevant links for various pages on Dash Enterprise.

Notice that this will run on `type` `closed`. This is because the Action will run garbage collection and remove the preview application when a PR is closed/merged to save resources on Dash Enterprise.

## Usage with a monorepo
The recommended strategy for using this action with a monorepo is by constructing a matrix of changed applications and passing that matrix to `de-deploy`.
