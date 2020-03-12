const functions = require('firebase-functions');
const Twitter = require('twitter-lite');

exports.twitterTest = functions.https.onRequest(async (request, response) => {
    
    // Configure Twitter application
    const app = new Twitter({
        bearer_token: functions.config().twitter.access_token,
    });

    // Get user's location from database
    var lat = 34.0522, long = -118.2437; // Los Angeles
    //console.log("hi");

    // Get closest WOEID with trends
    const woeidResponse = await app.get('trends/closest', {
        lat: lat,
        long: long,
    });
    var woeid = woeidResponse[0].woeid;
    var locationName = woeidResponse[0].name;

    // Get trends near the WOEID
    const trendsResponse = await app.get('trends/place', {
        id: woeid,
    });
    const trends = trendsResponse[0].trends;
    trends.forEach(trend => { console.log(trend.name); });

    //console.log('WOEID:', woeid);

    response.send(`${locationName} has ${trends.length} trends.`);

});
