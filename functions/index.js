const functions = require('firebase-functions');
const axios = require('axios').default;

exports.twitterTest = functions.https.onRequest((request, response) => {
    const accessToken = functions.config().twitter.access_token;
    var path = "/1.1/statuses/user_timeline.json?count=100&screen_name=twitterapi";
    var host = "https://api.twitter.com";

    axios.get(path, {
        baseURL: host,
        headers: {
            'Authorization': 'Bearer ' + accessToken,
        },
    }).then(res => {
        return response.send(res.data);
    }).catch(error => {
        response.send(error);
    });
});
