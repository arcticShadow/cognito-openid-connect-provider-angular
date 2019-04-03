This repo aims to provide guidance on the options required to use cognito User Pools as an Open ID Connect Provider.

Specifically, i've integrated into angular, but the lessons should be universal. 

This repo uses Terraform to spin up and manage the Cognito User Pool. It's not required, you can tak ethe lessons learned and apply manually, or via another tool. 

# Deployment & Setup
1. Get the repo

```bash
git clone git@github.com:arcticShadow/cognito-openid-connect-provider-angular.git
cd cognito-openid-connect-provider-angular
```

## Install terraform (if required)

```bash
brew install terraform
```

## Deploy Terraform

The terraform command uses `-var` to set  a terraform argument for User. Thi is used internally to tag some thigns, identifing who deployed it. I work in a multi user environment, and its super usefull to know who things belong to.

You can remove the user var requirment, or see and edit the other tags, in the `locals.tf` file. Just ensure you leave the map intact i.e. `common_resource_tags = {}` or else other things depending on it will fail. 

```bash
cd tf
terraform init # this is a one time command
terraform apply -var 'user=abc'
```

## Build and Run Angular App 

### Prepare 

Firstly, you need to collect some details from terraform and provide them to your angular app. 

From the `tf` directory, run 

```bash
terraform output
```

This will give you two outputs, `clientId` and `issuer` which need to be placed into a new file located at `web/src/environments/secret.ts` the `secret.ts` is referenced by the environment file, and is excluded from git, so you don't commit secrets by mistake. 

```
// secret.ts
export const secretConfig = {
  issuer: '',
  clientId: ''
};
```

### Build

```bash
cd web
ng serve -o
```

The above command will build and open in a browser (http://localhost:4200) which will check your auth status, and then redirect you to the cognito provided login page. 

You dont have a login at present, so you need to add a user, to the user pool, most likely in the AWS UI - [Ref](https://docs.aws.amazon.com/cognito/latest/developerguide/how-to-create-user-accounts.html)

# Explanation of Cognito Caveats and Problems requiring workaround

Cognito does some weird things that we need to work around, or bypass


## Custom Domain Required

Cognito requires a custom domain (even if its just a free domain from aws) to be setup, before the authorize endpoint will respond with any meaningfull response. 

I've added a custom domain to my pool with the terraform resource `aws_cognito_user_pool_domain` the name is trivial - and its reflected in the .well-known config file so you dont need to remember the domain. 


## No id_token in response_type

Typically, open id connect would request a id_token in the response type. Cognito, does not allow it.

The call to the authorization endpoint only accepts a response_type of `token` for implicit flow. However, it returns you an `id_token` to your callback, even though you didnt ask for it. (via `id_token token` response_type)

The library I have implemented, changes the response_type that is sent, in  `web/src/app/auth-config.js` file with the `responseType: 'token'` argument.


## Different hosts in openid-configuration

Some libraries have checks that enforce all urls in the `.well-known/openid-configuration` file to have the same hostname. For cognito to work, we need a custom domain for authorization, and that breaks this requirement. Differeing domains appears to be part of a spec somewhere, but i've lost the reference to it. 

The library i have implemented, disabls this check in the `web/src/app/auth-config.js` file with the `strictDiscoveryDocumentValidation: false` argument.


## Terraform cognito user pool defaults different from AWS UI defaults

When createing a userpool from terraform, some defaults the the UI will provide are skipped. These defaults are trivial, btu required. PLease look at the resources for `user_pool` and `app_client` in the `main.tf` file if you are interested.