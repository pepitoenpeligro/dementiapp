
import { Duration, aws_iam } from 'aws-cdk-lib';
import {
	RestApi,
	EndpointType,
	Cors,
	AuthorizationType,
	IdentitySource,
	LambdaIntegration,
	RequestAuthorizer,
} from 'aws-cdk-lib/aws-apigateway';
import { Runtime } from 'aws-cdk-lib/aws-lambda';
import { NodejsFunction } from 'aws-cdk-lib/aws-lambda-nodejs';
import { Lambda } from 'aws-cdk-lib/aws-ses-actions';
import { Construct } from 'constructs';

type ProtectedApiProps = {
	userPoolId: string;
	userPoolClientId: string;
};

export class ProtectedApi extends Construct {
	constructor(scope: Construct, id: string, props: ProtectedApiProps) {
		super(scope, id);

		const api = new RestApi(this, 'ProtectedApi', {
			description: 'Protected RestApi',
			endpointTypes: [EndpointType.REGIONAL],
			defaultCorsPreflightOptions: {
				allowOrigins: Cors.ALL_ORIGINS,
				allowMethods: Cors.ALL_METHODS
			},
		});

		// resources

		const protectedEndpoint = api.root.addResource('protected');

		const locationEndpoint = api.root.addResource('location');

		const usersEndpoint = api.root.addResource('users');

		const invitationsEndpoint = api.root.addResource('invitations');

		const linksEndpoint = api.root.addResource('links');

		// revisar
		const notificationsEndpoint = api.root.addResource('notifications');



		const commonFnProps = {
			runtime: Runtime.NODEJS_16_X,
			handler: 'handler',
			environment: {
				USER_POOL_ID: props.userPoolId,
				CLIENT_ID: props.userPoolClientId,
			},
		};


		// Authorizer
		const authorizerFn = new NodejsFunction(this, 'AuthorizerFn', {
			...commonFnProps,
			entry: './lambda/auth/authorizer.ts',
		});

		const requestAuthorizer = new RequestAuthorizer(this, 'RequestAuthorizer', {
			identitySources: [IdentitySource.header('Authorization')],
			handler: authorizerFn,
			resultsCacheTtl: Duration.minutes(0),
		});



		// props
		const usersProps = {
			runtime: Runtime.NODEJS_16_X,
			handler: 'handler',
			environment: {
				DynamoDBTable: 'testUsers',
			},
		};


		const invitationsProps = {
			runtime: Runtime.NODEJS_16_X,
			handler: 'handler',
			environment: {
				usersTable: 'testUsers',
				invitationsTable: 'testInvitations',
			},
		};


		const linksProps = {
			runtime: Runtime.NODEJS_16_X,
			handler: 'handler',
			environment: {
				usersTable: 'testUsers',
				invitationsTable: 'testInvitations',
				linksTable: 'testLinks',
			},
		}

		const locationProps = {
			runtime: Runtime.NODEJS_16_X,
			handler: 'handler',
			environment: {
				usersTable: 'testUsers',
				locationsTable: 'testLocations'
			},
		}

		const notificationsProps = {
			runtime: Runtime.NODEJS_16_X,
			handler: 'handler',
			environment: {
				GRAPHQL_ENDPOINT:"https://hx6p3rjzlvdvlekil24yiikwtm.appsync-api.eu-west-1.amazonaws.com/graphql",
				GRAPHQL_API_KEY: "da2-hugcdz64xjgy5fbwjx6ubfuhr4"
			}
		}

		

		// Example protected function
		const protectedFn = new NodejsFunction(this, 'ProtectedFn', {
			...commonFnProps,
			entry: './lambda/protected.ts',
		});
		

		protectedEndpoint.addMethod('GET', new LambdaIntegration(protectedFn), {
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM,
		});
		



		// LOCATIONS

		const setLocationRecord = new NodejsFunction(this, 'putLocation',{
			...locationProps,
			functionName: 'putLocation',
			entry: './lambda/locations/createLocation.js'
		});

		const kinesisPolicy = new aws_iam.PolicyStatement();
		kinesisPolicy.addActions("kinesis:putRecord");
		kinesisPolicy.addActions("dynamodb:PutItem");
		kinesisPolicy.addResources("*");
		setLocationRecord.addToRolePolicy(kinesisPolicy);

		locationEndpoint.addMethod('POST', new LambdaIntegration(setLocationRecord),{
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		})

		const getLocations = new NodejsFunction(this, 'getLocations',{
			...locationProps,
			functionName: 'getLocations',
			entry: './lambda/locations/getLocations.js'
		});


		const getLocationPolicy = new aws_iam.PolicyStatement();
		getLocationPolicy.addActions("dynamodb:GetItem");
		getLocationPolicy.addActions("dynamodb:PartiQLSelect");
		getLocationPolicy.addActions("dynamodb:Query");
		getLocationPolicy.addActions("dynamodb:UpdateItem");
		getLocationPolicy.addResources("*");
		getLocations.addToRolePolicy(getLocationPolicy);

		const locationById = locationEndpoint.addResource('{id}');
		locationById.addMethod('GET', new LambdaIntegration(getLocations), {
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM,
		});







		// USERS
		const updateUser = new NodejsFunction(this, 'updateUser',{
			...usersProps,
			functionName: 'updateUser',
			entry: './lambda/users/updateUser.js'
		});

		const dynamoPolicy = new aws_iam.PolicyStatement();
		dynamoPolicy.addActions("dynamodb:GetItem");
		dynamoPolicy.addActions("dynamodb:PartiQLSelect");
		dynamoPolicy.addActions("dynamodb:Query");
		dynamoPolicy.addActions("dynamodb:UpdateItem");
		dynamoPolicy.addResources("*");
		updateUser.addToRolePolicy(dynamoPolicy);


		const byId = usersEndpoint.addResource('{id}');
		// PUT '/users/:id'
		byId.addMethod('PUT', new LambdaIntegration(updateUser),{
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		})


		
		const createInvitation = new NodejsFunction(this, 'createInvitation',{
			...invitationsProps,
			functionName: 'createInvitation',
			entry: './lambda/invitations/createInvitation.js'
		});

		const getInvitations = new NodejsFunction(this, 'getInvitations',{
			...invitationsProps,
			functionName: 'getInvitations',
			entry: './lambda/invitations/getInvitations.js'
		});




		const createInvitationPolicy = new aws_iam.PolicyStatement();
		createInvitationPolicy.addActions("dynamodb:GetItem");
		createInvitationPolicy.addActions("dynamodb:PartiQLSelect");
		createInvitationPolicy.addActions("dynamodb:Query");
		createInvitationPolicy.addActions("dynamodb:PutItem");
		createInvitationPolicy.addResources("*");
		createInvitation.addToRolePolicy(createInvitationPolicy);

		invitationsEndpoint.addMethod('POST', new LambdaIntegration(createInvitation), {
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		});


		
		getInvitations.addToRolePolicy(dynamoPolicy);
		invitationsEndpoint.addMethod('GET', new LambdaIntegration(getInvitations), {
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		});




		const deleteInvitation = new NodejsFunction(this, 'deleteInvitation',{
			...invitationsProps,
			functionName: 'deleteInvitation',
			entry: './lambda/invitations/deleteInvitation.js'
		});

		const deleteInvitationPolicy = new aws_iam.PolicyStatement();
		deleteInvitationPolicy.addActions("dynamodb:GetItem");
		deleteInvitationPolicy.addActions("dynamodb:PartiQLSelect");
		deleteInvitationPolicy.addActions("dynamodb:Query");
		deleteInvitationPolicy.addActions("dynamodb:DeleteItem");
		deleteInvitationPolicy.addResources("*");
		deleteInvitation.addToRolePolicy(deleteInvitationPolicy);

		const invitationDeleteById = invitationsEndpoint.addResource('{id}');
		// PUT '/invitations/:id'
		invitationDeleteById.addMethod('DELETE', new LambdaIntegration(deleteInvitation),{
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		})





		const createLink = new NodejsFunction(this, 'createLink',{
			...linksProps,
			functionName: 'createLink',
			entry: './lambda/links/createLink.js'
		});

		const cretaLinkPolicy = new aws_iam.PolicyStatement();
		cretaLinkPolicy.addActions("dynamodb:GetItem");
		cretaLinkPolicy.addActions("dynamodb:PartiQLSelect");
		cretaLinkPolicy.addActions("dynamodb:Query");
		cretaLinkPolicy.addActions("dynamodb:DeleteItem");
		cretaLinkPolicy.addActions("dynamodb:PutItem");
		cretaLinkPolicy.addResources("*");
		createLink.addToRolePolicy(cretaLinkPolicy);


		linksEndpoint.addMethod('POST', new LambdaIntegration(createLink), {
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		})







		const getLinks = new NodejsFunction(this, 'getLinks',{
			...linksProps,
			functionName: 'getLinks',
			entry: './lambda/links/getLinks.js'
		});

		const getLinksPolicy = new aws_iam.PolicyStatement();
		getLinksPolicy.addActions("dynamodb:GetItem");
		getLinksPolicy.addActions("dynamodb:PartiQLSelect");
		getLinksPolicy.addActions("dynamodb:Query");
		getLinksPolicy.addResources("*");
		getLinks.addToRolePolicy(getLinksPolicy);

		linksEndpoint.addMethod('GET', new LambdaIntegration(getLinks),{
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		})
		

		const createNotification = new NodejsFunction(this, 'createNotification',{
			...notificationsProps,
			functionName: 'createNotification',
			entry: './lambda/notifications/createNotification.js'
		});

		notificationsEndpoint.addMethod('POST', new LambdaIntegration(createNotification), {
			authorizer: requestAuthorizer,
			authorizationType: AuthorizationType.CUSTOM
		});

	}
}