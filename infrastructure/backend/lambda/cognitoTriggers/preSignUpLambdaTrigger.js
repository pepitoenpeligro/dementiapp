const aws = require("aws-sdk");
const uuid = require("uuid");

const ddb = new aws.DynamoDB({ apiVersion: "2012-10-08" });

const getCognitoRegion = (event) => {
  return event.region;
};

const getCognitoPoolId = (event) => {
  return event.userPoolId;
};

const getUsername = (event) => {
  return event.userName;
};

const getEmail = (event) => {
  return event.request.userAttributes.email;
};

const createDBOptions = (event) => {
  const currentDate = new Date();
  const params = {
    TableName: process.env.DynamoDBTable,
    Item: {
      email: { S: getEmail(event) },
      userId: { S: uuid.v4() },
      displayName: { S: "" },
      userName: { S: getUsername(event) },
      profilePic: { S: "" },
      firstLogin: { BOOL: true },
      createdAt: { N: currentDate.getTime().toString() },
      cognito_region: { S: getCognitoRegion(event) },
      cognito_pool: { S: getCognitoPoolId(event) },
      participation: { S: "" },
    },
  };
  return params;
};

const saveUserToDynamoDB = async (params) => {
  return await ddb.putItem(params).promise();
};

exports.handler = async (event, context) => {
  console.log("Recibo");
  console.log(JSON.stringify(event));

  console.log("Proceso");
  console.log(getUsername(event));
  console.log(getEmail(event));
  console.log(getCognitoPoolId(event));
  console.log(getCognitoRegion(event));

  const params = createDBOptions(event);
  await saveUserToDynamoDB(params)
    .then((success) => {
      console.log(success);
    })
    .catch((error) => {
      console.log(error);
    });

  context.done(null, event);
};
