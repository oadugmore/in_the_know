const functions = require('firebase-functions');
const axios = require('axios').default;

exports.twitterTest = functions.https.onRequest((request, response) => {
    const accessToken = functions.config().twitter.access_token;
    var testPath = "/1.1/statuses/user_timeline.json?count=100&screen_name=twitterapi";
    var host = "https://api.twitter.com";
    var authHeaders = { 'Authorization': 'Bearer ' + accessToken };

    // get user's location from database
    var lat = 34, lon = 118;
    var woeid;
    //console.log("hi");

    // get WOEID from lat/lon
    axios.get(`https://api.twitter.com/1.1/trends/closest.json?lat=${lat}&long=${lon}`, {
        headers: authHeaders,
    }).then(res => {
        console.log(res.data);
        woeid = JSON.parse(res.data).woeid;
        console.log("WOEID: " + woeid);
        return response.end();
    }).catch(error => {
        console.log("Error: " + error);
        response.set(500).send();
    });

    // axios.get(testPath, {
    //     baseURL: host,
    //     headers: {
    //         'Authorization': 'Bearer ' + accessToken,
    //     },
    // }).then(res => {
    //     return response.send(res.data);
    // }).catch(error => {
    //     response.send(error);
    // });
});
