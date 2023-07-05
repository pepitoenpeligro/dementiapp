const axios = require('axios');
const uuid = require('uuid');

const buildQuery = (id, title, message, userId, timestamp) => {
  return `
      mutation MyMutation {
        createNotification(input: {id: "${id}", message: "${message}", title: "${title}", userId: "${userId}", timestamp: "${timestamp}" }) {
            id
            title
            message
            timestamp
        }
    }
  `;
};


exports.handler = async (event) => {
  const GRAPHQL_ENDPOINT = process.env.GRAPHQL_ENDPOINT;
  const GRAPHQL_API_KEY = process.env.GRAPHQL_API_KEY;
  const query = buildQuery(uuid.v4(), JSON.parse(event.body).notification.title, JSON.parse(event.body).notification.message, JSON.parse(event.body).notification.userId, new Date().getTime());
  console.log(query);
  
  await axios(
    {
      url: GRAPHQL_ENDPOINT,
      method: "post",
      headers: {
        "x-api-key": GRAPHQL_API_KEY,
        "Content-Type": "application/json"
      },
      data: {"query": query}
    }
  ).then((success)=>{
    console.log("BIEN");
    console.log(success);
    const responsee = {
      statusCode: 200,
      body: JSON.stringify(responseGraphQL)
    };
    return responsee;
  }).catch((error) => {
    console.log("MAL");
    console.error(error);
  })
  
  // console.log(JSON.stringify(responseGraphQL));
  const response = {
    statusCode: 200,
    body: JSON.stringify('ok')
  };
  return response;
};