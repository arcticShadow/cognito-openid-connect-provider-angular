import { Component, OnInit } from '@angular/core';
import { OAuthService } from 'angular-oauth2-oidc';


@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {

  constructor(private oauthService: OAuthService) { }

  public login() {
    this.oauthService.initImplicitFlow();
  }

  public logoff() {
    this.oauthService.logOut();
  }

  public get name() {
    const claims: {given_name?: string} = this.oauthService.getIdentityClaims();
    if (!claims) {
      return null;
    }

    return claims.given_name;
  }
  ngOnInit() {
  }

}
