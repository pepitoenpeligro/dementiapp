exports.handler = async function (event: any) {
  return {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Headers": "*",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": true,
    },

    body: "This route is protected :)",
  };
};
