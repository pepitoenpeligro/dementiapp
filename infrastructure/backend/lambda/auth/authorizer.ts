import { APIGatewayAuthorizerResult, APIGatewayRequestAuthorizerEvent } from 'aws-lambda';
import { CookieMap, createPolicy, parseCookies, verifyToken, parseAuthorization } from '../utils';

exports.handler = async (event: APIGatewayRequestAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
	console.log('[EVENT]', event);

	console.log("[parseCookie]")
	console.log(event.headers)

	// const cookies: CookieMap = parseCookies(event);


	const token = event?.headers.Authorization || event?.headers.authorization;
	// const token = parseAuthorization(event);
	console.log(`[Authorizer] token= ${token}`);
	// console.log(`[Authorizer] cookies= ${cookies}`);

	
	// console.log("el token");
	// console.log(authToken);
	// const token = event?.headers["Authorization"];



	if (!token) {
		console.log("[Authorizer] Token does not exists")
		return {
			principalId: '',
			policyDocument: createPolicy(event, 'Deny'),
		};
	}else{
		console.log("[Authorizer] Token Exists!")
		console.log(token);
	}

	// const verifiedJwtCookie = await verifyToken(cookies.token, process.env.USER_POOL_ID!);
	const verifiedAuthorizationtoken = await verifyToken(token, process.env.USER_POOL_ID!);
	// const verifiedJwtJWT = await verifyToken(authToken, process.env.USER_POOL_ID!);

	let principalIdConstraint = '';
	console.log(principalIdConstraint);
	// if(verifiedJwtCookie){
	// 	principalIdConstraint = verifiedJwtCookie.sub!.toString()
	// 	console.log(principalIdConstraint);
	// }

	if(verifiedAuthorizationtoken){
		principalIdConstraint = verifiedAuthorizationtoken.sub!.toString()
		console.log(principalIdConstraint);
	}

	// console.log(verifiedJwtCookie);
	console.log(verifiedAuthorizationtoken);
	

	
	// return {
	// 	principalId: principalIdConstraint,
	// 	policyDocument: createPolicy(event, (verifiedJwtCookie || verifiedAuthorizationtoken) ? 'Allow' : 'Deny'),
	// };
	const policyCreated = createPolicy(event, verifiedAuthorizationtoken ? 'Allow' : 'Deny');


	console.log(`[Authorizer] La politica creada es: ${policyCreated}`);

	return {
		principalId: principalIdConstraint,
		policyDocument: policyCreated,
	};

	// return {
	// 	principalId: verifiedJwtCookie ? verifiedJwtCookie.sub!.toString() : '',
	// 	policyDocument: createPolicy(event, verifiedJwtCookie ? 'Allow' : 'Deny'),
	// };
	// return {
	// 	principalId: verifiedJwtJWT ? verifiedJwtJWT.sub!.toString() : '',
	// 	policyDocument: createPolicy(event, verifiedJwtJWT ? 'Allow' : 'Deny'),
	// };
};
