# Dash Enterprise 5 Deploy Action

This action can be configured to enable automatic deployments to a Dash Enterprise 4 server for a Dash application.

## Inputs

### `create_apps`

**Required** Whether the script is allowed to create new applications on the instance when attempting to deploy. If `true`, it will use GraphQL to create a new app of the specified `APP_NAME` if that app does not exist.

### `app_name` 
**Required** The name of the app to be deployed to Dash Enterprise

### `suffix`
**Optional** A suffix for the application name.

## Secrets

### `DASH_ENTERPRISE_USERNAME` 
**Required** The username to use to deploy. The app will be deployed and this account will be assigned ownership.

### `DASH_ENTERPRISE_PASSWORD` 
**Required** The password for the user.

### `DASH_ENTERPRISE_HOST` 
**Required** The URL of the DE instance you are deploying to, without the https:// prefix. For example: dash-gallery.plotly.host

### `ACCESS_TOKEN`
**Required** A Github access token, required to install `dekn-cli-python`. This is available at (github.com/plotly/dekn-cli-python)[https://github.com/plotly/dekn-cli-python]. Docs on how to generate a personal access token can be found at (docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)[https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token]


## Example usage

To be added.
