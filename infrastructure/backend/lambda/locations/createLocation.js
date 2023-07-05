const AWS = require('aws-sdk');
const uuid = require('uuid');

const kinesis = new AWS.Kinesis({
  apiVersion: '2013-12-02',
  maxRetries: 3, 
  httpOptions: { connectTimeout: 1000, timeout: 1000 },
  region: 'eu-west-1'
});

const ddb = new AWS.DynamoDB({apiVersion: '2012-10-08'});
const dynamoDocumentClient = new AWS.DynamoDB.DocumentClient();
let response;

const pushToKineis = async (payload) => {
  return kinesis.putRecord(payload).promise();
}


const saveLocationToDynamoDB = (userId, latitude, longitude) => {
  const timestamp = new Date();
  const params = {
      TableName: process.env.locationsTable,
      Item: {
          'locationId': {'S':uuid.v4()},
          'userId': {'S': userId},
          'latitude': {'N': `${latitude}`},
          'longitude': {'N':`${longitude}`},
          'createdAt': {'N': timestamp.getTime().toString()},
      }
  };
  console.log("Voy a dynamo con estos parametros");
  console.log(params);
  return ddb.putItem(params).promise();
}

const extractUserId = (event) => {
  return JSON.parse(event.body).userId;
}

// latitude = lat
const extractLongitude = (event) => {
  return JSON.parse(event.body).location.longitude;
}

// longitude = lon
const extractLatitude = (event) => {
  return JSON.parse(event.body).location.latitude;
}

exports.handler = async (event) => {

  const dataEventExtract = JSON.stringify(event.body);
  const streamName = 'KinesisInputStream';
  const paritionKey = 'shardId-000000000000';

  let response_headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials": true,
    
  };

  let response = {
    statusCode: 400,
    headers: response_headers,
  };

  const payload = {
    Data: dataEventExtract,
    PartitionKey: paritionKey,
    StreamName: streamName
  };

  await pushToKineis(payload).then((success) => {
    console.log(`Successfully put record into Kinesis ${success}`);
    
    response = {
      statusCode: 201,
      headers: response_headers,
      
      body: JSON.stringify({
        message: "Location pushed successfully",
        code: 201
      }),
    };

  }).catch((error) => {

    console.error(`Error putting record into Kinesis ${error}`)
    // response = {
    //   statusCode: 404,
    //   headers: response_headers,
    //   body: JSON.stringify({
    //     message: "Error pushing location into kinesis stream",
    //     code: 404,
    //     error: error
    //   }),
    // };
  })

  const latitude = extractLatitude(event);
  const longitude = extractLongitude(event);
  const userId = extractUserId(event);

  await saveLocationToDynamoDB(userId, latitude, longitude).then((locationSuccess) => {
    console.log(`Location saved successfully to dynamodb ${JSON.stringify(locationSuccess)}`);
  }).catch((error) => {
    console.error(`Location not saved ${JSON.stringify(error)}`);
  });


  response = {
      statusCode: 200,
      headers: response_headers,
      body: JSON.stringify({
        message: "Location saved",
    }),
  };

  return response;  
};