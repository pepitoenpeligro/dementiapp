
const AWS = require('aws-sdk');
const uuid = require('uuid');

const ddb = new AWS.DynamoDB({apiVersion: '2012-10-08'});
const dynamoDocumentClient = new AWS.DynamoDB.DocumentClient();

const getInvitationId = (event) => {
    return event.pathParameters.id;
}


const deleteInvitation = async (invitationId) =>  {
    const currentDate = new Date();
    const params = {
        TableName: process.env.invitationsTable,
        Key: {
            'invitationId': invitationId,
        }
    };
    console.log("Voy a dynamo con estos parametros");
    console.log(params);
    return dynamoDocumentClient.delete(params).promise();
}

exports.handler = async (event, context) => {
    const headers = {
		'Access-Control-Allow-Headers': '*',
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Credentials': true
	};

    console.log("Recibo");
    console.log(JSON.stringify(event));

    await deleteInvitation(getInvitationId(event)).then((invitationResult) => {
        console.log(`Invitation deleted successfully ${invitationResult}`);
    }).catch((error) => {
        console.error(`Query error ${error}`);
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                body: "Invitation could not be deleted",
                error: error
            }),
        };
    });

    return {
        statusCode: 200,
        headers: headers,
        body: JSON.stringify({
            body: "Invitation deleted successfully",
        }),
    };


}