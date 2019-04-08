import { Injectable } from '@angular/core';
import { OAuthService } from 'angular-oauth2-oidc';

@Injectable({
  providedIn: 'root'
})
export class IdentityService {

  constructor(private oauthService: OAuthService) { }

  getUserinfo() {
    fetch('this.oauthService.userinfoEndpoint', {
      headers: {
        Authorization: `Bearer ${this.oauthService.getAccessToken()}`,
      }
    });
  }
}
