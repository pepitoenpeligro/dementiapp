const AWS = require('aws-sdk');
const { link } = require('fs');
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
		TableName: process.env.linksTable,
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
		TableName: process.env.linksTable,
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
        let links;
        let collection = [];
        
        if(participation === "cared"){
            // si soy un usuario cuidado
            // quiero saber quienes son las personas que me cuidan
            console.log("El usuario que pide tiene el participation a cared");
            collection = [];
            await getCared(user.email).then(async (success)=> {
                console.log(JSON.stringify(success));
                links = success.Items;


                links = success.Items;
                console.log("[A1] ");
                console.log(JSON.stringify(links));
                console.log("[B1] ");

                // para cada uno de los items, hacer la busqueda de los usuarios por email
                await Promise.all(
                    
                    links.map(async (link) => {
                    await searchUserByEmail(link.caretaker).then((success)=> {
                        collection.push(success.Items[0]);
                    });
                  }
                ));

            }).catch((error)=> {
                console.error(`Error searching links ${JSON.stringify(error)}`);
    
                return {
                    statusCode: 400,
                    headers: headers,
                    body: JSON.stringify({
                        message: "Links not found for this user",
                        error: error
                    }),
                };
    
            });
        }else if(participation === "caretaker"){
            console.log("El usuario que pide tiene el participation a caretaker");
            // si soy cuidador
            // quiero tener disponible las personas a las que cuido
            collection = [];
            await getCaretaker(user.email).then(async (success)=> {
                console.log(JSON.stringify(success));
                links = success.Items;

                console.log("[A2] ");
                console.log(JSON.stringify(links));
                console.log("[B2] ");

                // para cada uno de los items, hacer la busqueda de los usuarios por email
                await Promise.all(
                    
                    links.map(async (link) => {
                    await searchUserByEmail(link.cared).then((success)=> {
                        collection.push(success.Items[0]);
                    });
                  }
                ));

                // links.forEach(async (email) => {
                //     await searchUserByEmail(email).then((success)=> {
                //         collection.push(success.Items[0]);
                //     });
                //     console.log("[Y]Se supone que termina");
                //     console.log(collection);

                    
                // });

                console.log("[X]Se supone que termina");
                console.log(collection);


                
            }).catch((error)=> {
                console.error(`Error searching links ${JSON.stringify(error)}`);
    
                return {
                    statusCode: 400,
                    headers: headers,
                    body: JSON.stringify({
                        message: "Links not found for this user",
                        error: error
                    }),
                };
            });
        }


        return {
            statusCode: 200,
            headers: headers,
            body: JSON.stringify({
                links: collection
            }),
        };

}