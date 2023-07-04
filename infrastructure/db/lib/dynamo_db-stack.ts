import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { App, Stack, RemovalPolicy } from "aws-cdk-lib";


export class DynamoDbStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // DynamoDB Table
    const locationsTable = new cdk.aws_dynamodb.Table(this, "Locations", {
      partitionKey: {
        name: "locationId",
        type: cdk.aws_dynamodb.AttributeType.STRING,
      },
      tableName: "Locations",
      billingMode: cdk.aws_dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: RemovalPolicy.DESTROY,
    });


    const linksTable = new cdk.aws_dynamodb.Table(this, "Links", {
      partitionKey: {
        name: "linkId",
        type: cdk.aws_dynamodb.AttributeType.STRING,
      },
      tableName: "Links",
      billingMode: cdk.aws_dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: RemovalPolicy.DESTROY,
    });

    const usersTable = new cdk.aws_dynamodb.Table(this, "Users", {
      partitionKey: {
        name: "email",
        type: cdk.aws_dynamodb.AttributeType.STRING,
      },
      tableName: "Users",
      billingMode: cdk.aws_dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: RemovalPolicy.DESTROY,
    });

    const invitationsTable = new cdk.aws_dynamodb.Table(this, "Invitations", {
      partitionKey: {
        name: "invitationId",
        type: cdk.aws_dynamodb.AttributeType.STRING,
      },
      tableName: "Invitations",
      billingMode: cdk.aws_dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: RemovalPolicy.DESTROY,
    });

  }
}
