# Dash Enteprise Deploy

This is a GitHub Action to deploy a Dash application to Dash Enterprise 5.

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
      - uses: plotly/de5-deploy@main
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
      - uses: plotly/de5-deploy@main
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
      - uses: plotly/de5-deploy@main
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
      - uses: plotly/de5-deploy@main
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
```