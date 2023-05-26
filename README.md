# Netlify Deploy

This is a GitHub Action to deploy a Dash application to Dash Enterprise 5.

## Usage

To use a GitHub action you can just reference it on your Workflow file
(for more info check [this article by Github](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow))

```yml
name: 'Dash Enterprise Deploy'

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: 'Deploy to Dash Enterprise'
    steps:
      - uses: plotly/de5-deploy@latest
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GITHUB_ACCESS_TOKEN: ${{ secrets.GITHUB_ACCESS_TOKEN }}
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
| `GITHUB_ACCESS_TOKEN` | `true` | N/A | An access token for Github. |
| `DE_DEPLOY_TO_PROD` | `true` | `false` | Whether to deploy to the production namespace or to a deploy preview. |
| `app_name` | `false` | Repository name | The slug name for the application on DE. |
| `deploy_alias` | `false` | `None` | A suffix/alias for the application. The application will be deployed to `${app_name}-${deploy_alias}`. |


## Example

### Deploy to production on release

> You can setup repo secrets to use in your workflows

```yml
name: 'Dash Enterprise Deploy'

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de5-deploy@latest
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GITHUB_ACCESS_TOKEN: ${{ secrets.GITHUB_ACCESS_TOKEN }}
```

### Preview Deploy on pull request
Will deploy branches as `https://${DE_HOST}/${APP_NAME}-${event_number}`, e.g. if you are deploying an app called `inventory-analytics` to `example.plotly.host` and your PR number is `15`, the deploy preview would be available at `https://example.plotly.host/inventory-analytics-15` and would be redeployed on every new commit.

```yml
name: 'Dash Enterprise Preview Deploy'

on:
  pull_request:
    types: ['opened', 'edited', 'synchronize']

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: plotly/de5-deploy@latest
        with:
          DE_HOST: ${{ secrets.DE_HOST }}
          DE_USERNAME: ${{ secrets.DE_USERNAME }}
          DE_PASSWORD: ${{ secrets.DE_PASSWORD }}
          GITHUB_ACCESS_TOKEN: ${{ secrets.GITHUB_ACCESS_TOKEN }}
          DE_DEPLOY_TO_PROD: false
```

### Use branch name to deploy

Will deploy branches as `https://${branchName}--${siteName}.netlify.app`.

An action is used to extract the branch name to avoid fiddling with `refs/`. Finally, a commit status check is added, linking to the deployed site.

Only the default branch is built for simplicity. Use a similar workflow or standard Netlify integration for the production deployment.

```yml
name: 'Netlify Previews'

on:
  push:
    branches-ignore: 
      - master

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1

      # Sets the branch name as environment variable
      - uses: nelonoel/branch-name@v1.0.1
      - uses: jsmrcaga/action-netlify-deploy@master
        with:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
          deploy_alias: ${{ env.BRANCH_NAME }}
      
      # Creates a status check with link to preview
      - name: Status check
        uses: Sibz/github-status-action@v1.1.1
        with:
          authToken: ${{ secrets.GITHUB_TOKEN }}
          context: Netlify preview
          state: success
          target_url: ${{ env.NETLIFY_PREVIEW_URL }}
```

### Deploy to Netlify only

In case of already having the deployment ready data - we can easily skip the nvm, install and build part via passing:

```
- name: Deploy to Netlify
  uses: jsmrcaga/action-netlify-deploy@v2.0.0
  with:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
    NETLIFY_DEPLOY_MESSAGE: "Deployed from GitHub action"
    NETLIFY_DEPLOY_TO_PROD: true
    install_command: "echo Skipping installing the dependencies"
    build_command: "echo Skipping building the web files"
```

## Contributors

- [tpluscode](https://github.com/tpluscode)
- [wallies](https://github.com/wallies)
- [crisperit](https://github.com/crisperit)
