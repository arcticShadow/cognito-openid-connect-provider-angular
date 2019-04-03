import { secretConfig } from './secret.prod';

export const environment = {
  production: true,
  issuer: secretConfig.issuer,
  clientId: secretConfig.clientId
};
