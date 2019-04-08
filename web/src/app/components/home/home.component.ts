/// <reference types="aws-sdk" />
import { Component, OnInit } from '@angular/core';
import { OAuthService } from 'angular-oauth2-oidc';
import { IdentityService } from 'src/app/services/identity.service';
import * as AWS from 'aws-sdk';
import 'aws-sdk/clients/cognitoidentity';
import 'aws-sdk/clients/cognitoidentityserviceprovider';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  public users: [];

  constructor(
    private oauthService: OAuthService,
    private identityService: IdentityService
  ) { }

  public get name() {
    const claims: {'cognito:username'?: string} = this.oauthService.getIdentityClaims();
    if (!claims) {
      return null;
    }


    return claims['cognito:username'];
  }

  ngOnInit() {
    // this.identityService.getUserinfo();
    this.userList();
  }

  async userList() {
    // AWS.config.update({region: 'us-west-2'});
    AWS.config.region = 'us-west-2';
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
      // IdentityPoolId : 'us-west-2:"${environment.userPoolId}"', // your identity pool id here
      // IdentityPoolId : `us-west-2:"${environment.userPoolId}"`, // your identity pool id here
      IdentityPoolId : environment.identityPoolId, // your identity pool id here
      Logins : {
          // Change the key below according to the specific region your user pool is in.
          'cognito-idp.us-west-2.amazonaws.com/us-west-2_Si9ZJLnvl' : this.oauthService.getIdToken() // .getIdToken().getJwtToken()
      }
    });
    console.log(AWS.config.credentials);

    const cisp = new AWS.CognitoIdentityServiceProvider();
    const result = await cisp.listUsers({
      UserPoolId: environment.userPoolId,

    }).promise();
    console.log(result);
    this.users = result;

    //refreshes credentials using AWS.CognitoIdentity.getCredentialsForIdentity()
    // (AWS.config.credentials as AWS.CognitoIdentityCredentials).refresh((error) => {
    //     if (error) {
    //         console.error(error);
    //     } else {
    //         // Instantiate aws sdk service objects now that the credentials have been updated.
    //         // example: var s3 = new AWS.S3();
    //         console.log('Successfully logged!');
    //     }
    // });

  }
// aws-amplify/amplify-js
// packages/amazon-cognito-identity-js/
}
