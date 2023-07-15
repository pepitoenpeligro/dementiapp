
const AWS = require('aws-sdk');
// const uuid = require('uuid');

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

const saveInvitation = async (userCaretaker, userCared) =>  {
    const currentDate = new Date();
    const params = {
        TableName: process.env.invitationsTable,
        Item: {
            'invitationId': {'S':AWS.util.uuid.v4()},
            'caretaker': {'S': userCaretaker.email},
            'cared': {'S':userCared.email},
            'createdAt': {'N': currentDate.getTime().toString()},
        }
    };
    console.log("Voy a dynamo con estos parametros");
    console.log(params);
    return ddb.putItem(params).promise();
}


exports.handler = async (event, context) => {
    const headers = {
		'Access-Control-Allow-Headers': '*',
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Credentials': true
	};

    console.log("Recibo");
    console.log(JSON.stringify(event));

    // Recibo el email del usuario que pide crear la invitación
    // Recibo el email del usuario que va a ser cuidado

    // {
    //     "invitation"{
    //         "caretaker": "juan@gmail.com",
    //         "cared": "pepito@gmail.com"
    //     }
    // }

    // Busco el usuario completo que crea la invitación
    // Busco el usuario completo del usuario que va a ser cuidado

    // creo un objeto en la tabla testInvitations
    // con el id del usuario que pide y el id del usuario que va a ser cuidado.


    // Buscamos por email
    console.log("[1] Buscamos el usuario caretaker");
    let userCaretaker;
    console.log(JSON.parse(event.body));
    console.log(JSON.parse(event.body).invitation);
    console.log(JSON.parse(event.body).invitation.caretaker);
    const emailCaretaker = JSON.parse(event.body).invitation.caretaker;
    await searchUserByEmail(emailCaretaker).then((success)=>{
        console.log("caretaker user found: ");
        console.log(JSON.stringify(success));
        userCaretaker = success.Items[0];
    }).catch((error)=> {
        console.log("caretaker user not found: ");
        console.log(JSON.stringify(error));
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                body: "Caretaker email was not found",
                error: JSON.stringify(error),
            }),
        };
    });

    console.log("[2] Buscamos el usuario cared");
    let userCared;
    const emailCared = JSON.parse(event.body).invitation.cared;
    await searchUserByEmail(emailCared).then((success)=>{
        console.log("Cared user found: ");
        console.log(JSON.stringify(success));
        userCared = success.Items[0];
    }).catch((error)=> {
        console.log("Cared user not found: ");
        console.log(JSON.stringify(error));
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                body: "Cared email was not found",
                error: JSON.stringify(error),
            }),
        };
    });
    

    // Se presupone que ya tengo a los dos usuarios pillados
    console.log("[3] Creamos la invitacion");
    await saveInvitation(userCaretaker, userCared).then((success)=>{
        console.log("Invitation created successfully");
        console.log(JSON.stringify(success));
    }).catch((error)=> {
        console.error("Invitation was not created");
        console.error(JSON.stringify(error));
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                body: "Invitation was not created",
                error: JSON.stringify(error),
            }),
        };
    })





	return {
		statusCode: 200,
		headers: headers,
		body: JSON.stringify({
            body: "Invitation created successfully"
        }),
	};

};