
const AWS = require('aws-sdk');
const uuid = require('uuid');

const ddb = new AWS.DynamoDB({apiVersion: '2012-10-08'});
const dynamoDocumentClient = new AWS.DynamoDB.DocumentClient();


const getInvitationId = (event) => {
    return JSON.parse(event.body).invitation.invitationId;
}


const saveLink = async (userCaretaker, userCared) =>  {
    const currentDate = new Date();
    const params = {
        TableName: process.env.linksTable,
        Item: {
            'linkId': {'S':uuid.v4()},
            'caretaker': {'S': userCaretaker},
            'cared': {'S':userCared},
            'createdAt': {'N': currentDate.getTime().toString()},
        }
    };
    console.log("Voy a dynamo con estos parametros");
    console.log(params);
    return ddb.putItem(params).promise();
}


const deleteInvitation = async (invitationId) =>  {
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


const getInvitation = async (invitationId) =>  {
    const params = {
        TableName: process.env.invitationsTable,
        Key: {
            'invitationId': invitationId,
        },
        Limit: 1
    };
    console.log("Voy a dynamo con estos parametros");
    console.log(params);
    return dynamoDocumentClient.get(params).promise();
}



// responsable de crear un vinculo 
// recibe: 
// email cared
// email takecare
// id invitacion


exports.handler = async (event, context) => {
    const headers = {
		'Access-Control-Allow-Headers': '*',
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Credentials': true
	};

    console.log("Recibo");
    console.log(JSON.stringify(event));

    // Buscamos la invitación

    const invitationId = getInvitationId(event);
    let invitation = undefined;
    console.log(`Invitation id received: ${invitationId}`);
    await getInvitation(invitationId).then((success) => {
        console.log(`Invitation found: ${JSON.stringify(success)}`);
        invitation = success.Item;
        console.log(`Invitation found: ${invitation}`);
        

    }).catch((error) => {
        console.error(`Invitation not found ${error}`);
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                body: "Invitation not found",
                error: JSON.stringify(error),
            }),
        };
    })


    if (invitation != undefined){
        // si se encontró, eliminamos la invitación
        console.log(`Vamos a eliminar la invitacion ${invitation.invitationId}`);
        await deleteInvitation(invitation.invitationId).then((success)=>{
            console.log(`Invitation deleted succesfully ${success}`);
        }).catch((error)=>{
            console.error(`Invitation could not be deleted ${error}`);
            return {
                statusCode: 400,
                headers: headers,
                body: JSON.stringify({
                    body: "Invitation could not be deleted",
                    error: JSON.stringify(error),
                }),
            };
        })

        // Creamos el vinculo

        await saveLink(invitation.caretaker, invitation.cared).then((success)=> {
            console.log(`Link saved successfully ${success}`);
            
        }).catch((error)=> {
            console.error(`Link was not created ${error}`);
            return {
                statusCode: 400,
                headers: headers,
                body: JSON.stringify({
                    body: "Link was not created",
                    error: JSON.stringify(error),
                }),
            };
        })
    }

    return {
        statusCode: 200,
        headers: headers,
        body: JSON.stringify({
            body: "Link was created",
        }),
    };




}

