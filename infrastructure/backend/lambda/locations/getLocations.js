const AWS = require('aws-sdk');

const kinesis = new AWS.Kinesis({
  apiVersion: '2013-12-02',
  maxRetries: 3, 
  httpOptions: { connectTimeout: 1000, timeout: 1000 },
  region: 'eu-west-1'
});

const ddb = new AWS.DynamoDB({apiVersion: '2012-10-08'});
const dynamoDocumentClient = new AWS.DynamoDB.DocumentClient();

const getLocations = async (userId) => {
    const dynamoQueryParams = {
		// DynamoDB Table
		TableName: process.env.locationsTable,
        IndexName : "userId-index",
		KeyConditionExpression: "#userId = :userId",
		ExpressionAttributeNames: {
			"#userId": "userId"
		},
		ExpressionAttributeValues: {
			":userId": userId
		}
	};

    console.log(dynamoQueryParams);
    return dynamoDocumentClient.query(dynamoQueryParams).promise();
}


exports.handler = async (event, context) => {
    const headers = {
		'Access-Control-Allow-Headers': '*',
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Credentials': true
	};

    console.log("Recibo");
    console.log(JSON.stringify(event));

    const userId = event.pathParameters.id;

    let locationsCollection;

    await getLocations(userId).then((successGetLocations) => {
        console.log(`Locations retrieved successfully ${JSON.stringify(successGetLocations.Count)}`);
        locationsCollection = successGetLocations.Items;
        // locationsCollection.forEach(function(currentItem) {
        //     delete currentItem["userId"];
        // });
    }).catch((error) => {
        console.error(`Locations could not be retrieved ${error}`);
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                message: "Locations could not be retrieved",
                error: error,
            }),
        };

    });

    return {
        statusCode: 200,
        headers: headers,
        body: JSON.stringify({
            locations: locationsCollection,
        }),
    };


}
