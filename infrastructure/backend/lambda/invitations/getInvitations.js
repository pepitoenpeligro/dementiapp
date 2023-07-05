const AWS = require('aws-sdk');
const uuid = require('uuid');

const ddb = new AWS.DynamoDB({apiVersion: '2012-10-08'});
const dynamoDocumentClient = new AWS.DynamoDB.DocumentClient();


const searchUserByEmail = async (email) => {
    var dynamoQueryParams = {
		// DynamoDB Table
		TableName: process.env.usersTable,
		KeyConditionExpression: "#email = :email",
		ExpressionAttributeNames: {
			"#email": "email"
		},
		ExpressionAttributeValues: {
			":email": email
		},
		Limit: 1
	};

    return dynamoDocumentClient.query(dynamoQueryParams).promise();
}


const getCared = async (email) => {
    const dynamoQueryParams = {
		// DynamoDB Table
		TableName: process.env.invitationsTable,
        IndexName : "cared-index",
		KeyConditionExpression: "#cared = :cared",
		ExpressionAttributeNames: {
			"#cared": "cared"
		},
		ExpressionAttributeValues: {
			":cared": email
		}
	};

    console.log(dynamoQueryParams);

    return dynamoDocumentClient.query(dynamoQueryParams).promise();

}

const getCaretaker = async (email) => {
    const dynamoQueryParams = {
		// DynamoDB Table
		TableName: process.env.invitationsTable,
        IndexName : "caretaker-index",
		KeyConditionExpression: "#caretaker = :caretaker",
		ExpressionAttributeNames: {
			"#caretaker": "caretaker"
		},
		ExpressionAttributeValues: {
			":caretaker": email
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

    //queryParam:email
    const receivedEmail = event.queryStringParameters.email;

    // buscamos el usuario con ese email, y sacamos el participant
    let user;
    let statusCode;
    let body;

    await searchUserByEmail(receivedEmail).then((success)=>{
        console.log("User founded");
        console.log(success.Items[0]);
        user = success.Items[0];
        console.log(`User: ${user}`);
    }).catch((error) => {
        console.error(`Error searching user by this email ${JSON.stringify(error)}`);
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                message: "User not found",
                error: error
            }),
        };
    });

    const participation = user.participation;

    let invitations;

    // si es cared,
    // sacar la lista de la tabla testInvitations donde cared=user.email
    if(participation === "cared"){
        await getCared(user.email).then((success)=> {
            console.log(JSON.stringify(success));
            invitations = success.Items;
        }).catch((error)=> {
            console.error(`Error searching invitations ${JSON.stringify(error)}`);

            return {
                statusCode: 400,
                headers: headers,
                body: JSON.stringify({
                    message: "Invitations not found for this user",
                    error: error
                }),
            };

        });
    }else if(participation === "caretaker"){
        await getCaretaker(user.email).then((success)=> {
            console.log(JSON.stringify(success));
            invitations = success.Items;
            return {
                statusCode: 200,
                headers: headers,
                body: JSON.stringify({
                    invitations: JSON.stringify(success.Items)
                }),
            };
        }).catch((error)=> {
            console.error(`Error searching invitations ${JSON.stringify(error)}`);

            return {
                statusCode: 400,
                headers: headers,
                body: JSON.stringify({
                    message: "Invitations not found for this user",
                    error: error
                }),
            };
        });
    }

    
    return {
        statusCode: 200,
        headers: headers,
        body: JSON.stringify({
            invitations: invitations
        }),
    };
    

};