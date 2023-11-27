import { Injectable } from '@nestjs/common';
import { AppleLoginDto } from './dto/appleLogin.dto';
import * as jwt from 'jsonwebtoken';
import * as jwksClient from 'jwks-rsa';

@Injectable()
export class LoginService {
  private jwksClient: jwksClient.JwksClient;
  constructor() {
    this.jwksClient = jwksClient({
      jwksUri: 'https://appleid.apple.com/auth/keys',
    });
  }

  decodeIdentityToken(identityToken: string) {
    const identityTokenParts = identityToken.split('.');
    const identityTokenPayload = identityTokenParts[1];

    const payloadClaims = Buffer.from(
      identityTokenPayload,
      'base64',
    ).toString();

    return payloadClaims;
  }

  async getApplePublicKey(kid: string) {
    const client = jwksClient({
      jwksUri: 'https://appleid.apple.com/auth/keys',
    });

    const key = await client.getSigningKey(kid);
    const signingKey = key.getPublicKey();

    return signingKey;
  }

  async appleOAuth(body: AppleLoginDto) {
    console.log(body);
    const payloadClaims = this.decodeIdentityToken(body.identity_token); // 토큰을 디코딩해서 페이로드를 가져옴
    const payloadClaimsJson = JSON.parse(payloadClaims);

    const applePublicKey = await this.getApplePublicKey(payloadClaimsJson.kid);

    const isVerified: any = jwt.verify(
      body.identity_token,
      applePublicKey,
      {},
      (err, decoded) => {
        if (err) {
          return false;
        }
        console.log(decoded);
        return decoded;
      },
    );

    if (isVerified) {
      return { oAuthDomain: 'apple', sociald: payloadClaimsJson.sub };
    } else {
      return null;
    }
  }
}
