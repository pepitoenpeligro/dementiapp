import { Duration, RemovalPolicy, aws_cognito, aws_iam } from 'aws-cdk-lib';
import { UserPool, AutoVerifiedAttrs } from 'aws-cdk-lib/aws-cognito';
import { Construct } from 'constructs';
import { NodejsFunction } from 'aws-cdk-lib/aws-lambda-nodejs';
import { Runtime, Alias } from 'aws-cdk-lib/aws-lambda';
import { join } from 'path';


export class CognitoUserPool extends Construct {
	readonly userPoolId: string;
	readonly userPoolClientId: string;

	constructor(scope: Construct, id: string) {
		super(scope, id);

		const userPool = new UserPool(this, 'UserPool', {
			signInAliases: { username: true, email: true },
			selfSignUpEnabled: true,
			autoVerify: {email: true },
			removalPolicy: RemovalPolicy.DESTROY,
		});

		const appClient = userPool.addClient('AppClient', {
			authFlows: { userPassword: true },
		});

		this.userPoolId = userPool.userPoolId;
		this.userPoolClientId = appClient.userPoolClientId;

		const preSignUpLambdaTrigger = new NodejsFunction(this, 'preSignUpLambdaTrigger', {
			functionName: 'preSignUpLambdaTrigger',
			depsLockFilePath: (join(__dirname, '..', 'lambda', 'cognitoTriggers', 'package-lock.json')),
			runtime: Runtime.NODEJS_16_X,
			handler: 'handler',
			environment: {
				DynamoDBTable: 'testUsers',
			},
			bundling: {
				commandHooks: {
				  beforeBundling(inputDir: string, outputDir: string) {
					return [
					  `cd ${inputDir}`,
					  'yarn install --frozen-lockfile',
					]
				  },
				  beforeInstall() {
					return []
				  },
				  afterBundling() {
					return []
				  }
				}
			  },
			entry: (join(__dirname, '..', 'lambda', 'cognitoTriggers', 'preSignUpLambdaTrigger.js')),
			// entry: './lambda/cognitoTriggers/preSignUpLambdaTrigger.js',
			timeout: Duration.seconds(60),
			// ephemeralStorageSize: Size.gibibytes(0.5),
			memorySize: 128,
			description: "Handle pre sign up trigger in cognito (after user sign up)",

			// bundling: {
			// 	minify: true
			// }
		});

		const preSignUpLambdaTriggerPolicy = new aws_iam.PolicyStatement();
		preSignUpLambdaTriggerPolicy.addActions("dynamodb:PutItem");
		preSignUpLambdaTriggerPolicy.addResources("*");
		preSignUpLambdaTrigger.addToRolePolicy(preSignUpLambdaTriggerPolicy);

		userPool.addTrigger(aws_cognito.UserPoolOperation.PRE_SIGN_UP, preSignUpLambdaTrigger);
	}
}