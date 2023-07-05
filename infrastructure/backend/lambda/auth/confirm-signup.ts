import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { CognitoIdentityServiceProvider } from 'aws-sdk';
import { ConfirmSignUpRequest } from 'aws-sdk/clients/cognitoidentityserviceprovider';

const cognito = new CognitoIdentityServiceProvider();

type eventBody = { username: string; code: string };

exports.handler = async function (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
	console.log('[EVENT]', event);

	if (!event.body) {
		return {
			statusCode: 404,
			headers: {
				'Access-Control-Allow-Headers': '*',
				'Access-Control-Allow-Origin': '*',
				'Access-Control-Allow-Credentials' : true
			},
			body: JSON.stringify({
				message: 'You must provide a verifcation code',
			}),
		};
	}

	const { username, code }: eventBody = JSON.parse(event.body);

	const params: ConfirmSignUpRequest = {
		ClientId: process.env.CLIENT_ID!,
		Username: username,
		ConfirmationCode: code,
	};

	try {
		const res = await cognito.confirmSignUp(params).promise();
		console.log('[AUTH]', res);

		return {
			statusCode: 200,
			headers: {
				'Access-Control-Allow-Headers': '*',
				'Access-Control-Allow-Origin': '*',
				'Access-Control-Allow-Credentials' : true
			},
			body: JSON.stringify({
				message: `User ${username} successfully confirmed`,
				confirmed: true,
			}),
		};
	} catch (err) {
		return {
			statusCode: 404,
			headers: {
				'Access-Control-Allow-Headers': '*',
				'Access-Control-Allow-Origin': '*',
				'Access-Control-Allow-Credentials' : true
			},
			body: JSON.stringify({
				message: err,
			}),
		};
	}
};
