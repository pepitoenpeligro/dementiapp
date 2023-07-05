import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { CookieMap, parseAuthorization, parseCookies, verifyToken } from '../utils';
const AWS = require("aws-sdk");

exports.handler = async function (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
	console.log('[CurrentUser-event]', event);
	const token = event?.headers.Authorization;

	if (!token) {
		return {
			statusCode: 200,
			headers: {
				'Access-Control-Allow-Headers': '*',
				'Access-Control-Allow-Origin': '*',
				'Access-Control-Allow-Credentials': true
			},
			body: JSON.stringify({
				message: "You need to set the Authorization token"
			}),
		};
	}

	const verifiedJwt = await verifyToken(token, process.env.USER_POOL_ID!);
	const sub = verifiedJwt ? verifiedJwt.sub : null;
	const email = verifiedJwt ? verifiedJwt.email : null;

	if (email === null) {
		return {
			statusCode: 200,
			headers: {
				'Access-Control-Allow-Headers': '*',
				'Access-Control-Allow-Origin': '*',
				'Access-Control-Allow-Credentials': true
			},
			body: JSON.stringify({
				message: "Your token is invalid"
			}),
		};
	}

	var dynamoDocumentClient = new AWS.DynamoDB.DocumentClient();
	var dynamoQueryParams = {
		// DynamoDB Table
		TableName: "testUsers",
		KeyConditionExpression: "#email = :email",
		ExpressionAttributeNames: {
			"#email": "email"
		},
		ExpressionAttributeValues: {
			":email": email
		},
		Limit: 1
	};

	let userValues = {};
	await dynamoDocumentClient.query(dynamoQueryParams, function (err: any, data: { Items: any[]; }) {
		if (err) {
			console.error("Unable to query. Error:", JSON.stringify(err, null, 2));
		} else {
			console.log("Query succeeded.");
			userValues = data.Items[0];
		}
	}).promise();

	const headers = {
		'Access-Control-Allow-Headers': '*',
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Credentials': true
	};

	const responseData = {
		'email': userValues.email,
		'firstLogin': userValues.firstLogin,
		'profilePic': userValues.profilePic,
		'createdAt': userValues.createdAt,
		'userName': userValues.userName,
		'userId': userValues.userId,
		'participation': userValues.participation,
		'displayName': userValues.displayName,

	};

	return {
		statusCode: 200,
		headers: headers,
		body: JSON.stringify(responseData),
	};
};
