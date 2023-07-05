
const AWS = require('aws-sdk');
const dynamoDocumentClient = new AWS.DynamoDB.DocumentClient();

const getUserId = (event) => {
    return event.pathParameters.id;
}

const getUserDisplayName = (event) => {
    return JSON.parse(event.body).displayName;
}

const getUserBirthDate = (event) => {
    return JSON.parse(event.body).birthdate;
}

const getUserRole = (event) => {
    return JSON.parse(event.body).participation;
}

const getUserProfilePic = (event) => {
    return JSON.parse(event.body).profilePic;
}

const updateUserDynamoDB = async (event, user) =>  {
    const params = {
        TableName: process.env.DynamoDBTable,
        Key: {
            "email": user.email
        },
        UpdateExpression: "set displayName = :d, birthdate = :b, participation = :r, profilePic = :p, firstLogin = :f",
        ExpressionAttributeValues:{
            ":d" : getUserDisplayName(event),
            ":b" : getUserBirthDate(event),
            ":r" : getUserRole(event),
            ":p" : getUserProfilePic(event),
            ":f" : false
        },
        ReturnValues:"UPDATED_NEW"
    };
    return dynamoDocumentClient.update(params).promise();
}


const searchById = async (event) => {
    const dynamoQueryParams = {
		// DynamoDB Table
		TableName: process.env.DynamoDBTable,
        IndexName : "userId-index",
		KeyConditionExpression: "#userId = :userId",
		ExpressionAttributeNames: {
			"#userId": "userId"
		},
		ExpressionAttributeValues: {
			":userId": getUserId(event)
		},
		Limit: 1
	};

    console.log("Buscando por id");
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

    console.log("El ID de cognito");
    console.log(getUserId(event));

    console.log("El body");
    console.log(JSON.stringify(event.body));

    // Buscamos el usuario por ID
    let user;
    await searchById(event).then((userResult) => {
        user = userResult.Items[0]
        console.log(`El usuario es: ${JSON.stringify(user)}`);
        
    }).catch((error) => {
        console.error(`Query error ${error}`);
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                body: "User does not exists",
                error: error
            }),
        };
    })

    await updateUserDynamoDB(event, user).then((updateResult) => {
        console.log("Update success");
        console.log(JSON.stringify(updateResult));
        
        
    }).catch((error) => {
        console.error(`Error updating user ${error}`);
        return {
            statusCode: 400,
            headers: headers,
            body: JSON.stringify({
                body: "User could not be updated",
                error: error
            }),
        };
    })

    

	

	return {
		statusCode: 200,
		headers: headers,
		body: JSON.stringify({
            body: "User Updated successsfully"
        }),
	};

};
