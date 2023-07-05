import * as cdk from "aws-cdk-lib";

import { RemovalPolicy } from "aws-cdk-lib";
import { UserPool } from "aws-cdk-lib/aws-cognito";
import { Construct } from "constructs";

import { AuthApi } from "./auth-api";
import { ProtectedApi } from "./protected-api";
import { CognitoUserPool } from "./user-pool";

export class CognitoStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    const userPool = new CognitoUserPool(this, "UserPool");

    const { userPoolId, userPoolClientId } = userPool;

    const authApi = new AuthApi(this, "AuthServiceApi", {
      userPoolId,
      userPoolClientId,
    });

    const protectedApi = new ProtectedApi(this, "ProtectedApi", {
      userPoolId,
      userPoolClientId,
    });
  }
}
