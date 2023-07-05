import {
	APIGatewayRequestAuthorizerEvent,
	APIGatewayAuthorizerEvent,
	PolicyDocument,
	APIGatewayProxyEvent,
} from 'aws-lambda';

const axios = require('axios');
const jwkToPem = require('jwk-to-pem');
const jwt = require('jsonwebtoken');

export type CookieMap = { [key: string]: string } | undefined;
export type JwtToken = { sub: string; email: string } | null;
export type Jwk = {
	keys: {
		alg: string;
		e: string;
		kid: string;
		kty: string;
		n: string;
		use: string;
	}[];
};

export const parseCookies = (event: APIGatewayRequestAuthorizerEvent | APIGatewayProxyEvent) => {
	console.log("[parseCookie]")
	console.log(event.headers)
	
	if (!event.headers || !event.headers.Cookie) {
		return undefined;
	}

	const cookiesStr = event.headers.Cookie;
	const cookiesArr = cookiesStr.split(';');

	const cookieMap: CookieMap = {};

	for (let cookie of cookiesArr) {
		const cookieSplit = cookie.trim().split('=');
		cookieMap[cookieSplit[0]] = cookieSplit[1];
	}

	return cookieMap;
};

export const parseAuthorization = (event: APIGatewayRequestAuthorizerEvent | APIGatewayProxyEvent) => {
	
	if (!event.headers || !event.headers.Authorization || !event.headers.authorization) {
		return undefined;
	}



	const authorizationToken: string = event.headers.Authorization || event.headers.authorization;

	return authorizationToken;
} 

export const verifyToken = async (token: string, userPoolId: string): Promise<JwtToken> => {
	try {
		const url = `https://cognito-idp.eu-west-1.amazonaws.com/${userPoolId}/.well-known/jwks.json`;

		const { data }: { data: Jwk } = await axios.get(url);
		const pem = jwkToPem(data.keys[0]);

		const verification = jwt.verify(token, pem, { algorithms: ['RS256'] });
		console.log("[verifyToken] Verificacion")
		console.log(verification);
		return verification
	} catch (err) {
		console.log(err);
		return null;
	}
};

export const createPolicy = (event: APIGatewayAuthorizerEvent, effect: string): PolicyDocument => {
	console.log(`[createPolicy] creating policy for ${event.methodArn} and ${effect}`);
	return {
		Version: '2012-10-17',
		Statement: [
			{
				Effect: effect,
				Action: 'execute-api:Invoke',
				Resource: [event.methodArn],
			},
		],
	};
};