const functions = require('firebase-functions');
const Twitter = require('twitter-lite');
const { NlpManager } = require('node-nlp');
const readline = require('readline');
const trainnlp = require('./train-nlp');

exports.entityRecognitionTest = functions.https.onRequest(async (request, response) => {
    const manager = new NlpManager({ languages: ['en'] });
    const threshold = 0.5;

    await trainnlp(manager, say);
    //say('Say something!');
    line = request.query.line;
    // const rl = readline.createInterface({
    //     input: process.stdin,
    //     output: process.stdout,
    //     terminal: false,
    // });
    //rl.on('line', async line => {
    // if (line.toLowerCase() === 'quit') {
    //     rl.close();
    //     process.exit();
    // } else {
    const result = await manager.process(line);
    const answer =
        result.score > threshold && result.answer
            ? result.answer
            : "Sorry, I don't understand";
    let sentiment = '';
    if (result.sentiment.score !== 0) {
        sentiment = `  ${result.sentiment.score > 0 ? ':)' : ':('}   (${
            result.sentiment.score
            })`;
    }
    say(`bot> ${answer}${sentiment}`);
    response.send(result);
    //}
    //});
});

function say(message) {
    // eslint-disable-next-line no-console
    console.log(message);
}

exports.twitterTest = functions.https.onRequest(async (request, response) => {

    // Configure Twitter application
    const app = new Twitter({
        bearer_token: functions.config().twitter.access_token,
    });

    // Get user's location from database
    var lat = 32.7479, long = -117.1647; // Los Angeles
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
