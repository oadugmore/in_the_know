import spacy
import os
from twitter import *
from dotenv import load_dotenv
import json
load_dotenv()

model_dir = './models'
score_threshold = 5


def hello(request):
    # Use the base model from spaCy
    nlp = spacy.load('en_core_web_sm')
    ruler = spacy.pipeline.EntityRuler(nlp)

    # twitter = Twitter(auth=OAuth2(
    #     bearer_token=os.environ.get('TWITTER_ACCESS_TOKEN')))

    lat = 40.8324
    long = -115.7631  # Elko

    #trendsResult = (twitter.trends.closest(lat=lat, long=long))[0]
    #placeName = trendsResult['name']
    #print('Place name:', placeName)

    # instead of using trends API since it has a smaller rate limit
    request_args = request.args
    if request_args and 'loc' in request_args:
        placeName = request_args['loc']
    else:
        placeName = "Elko"

    #sentence = "Breaking: police activity reported at 11:02 AM in San Diego, the area between Grand Avenue and the CA-163 has been blocked off by SDPD."
    #sentence = "San Diego police respond to shots fired in Hillcrest. Avoid the area due to police activity"
    #sentence = "Please avoid the area of 4000 Boston Ave. due to police activity. The media staging location is at 40th and Z Street. Check back for further updates."

    #searchRequest = twitter.search.tweets(q=placeName, lang="en", count=50)
    searchRequest = {  # Sample search request
        "statuses": [
            {
                "text": "2 civilians were shot earlier.",
                "user": {"verified": False}
            }
        ]
    }

    # Add "situation" patterns
    patterns = [
        {"label": "SITUATION", "id": "Gunfire", "pattern": [
            {"LOWER": {"REGEX": "^(gun)?shots?"}},
            {"LOWER": {"REGEX": "^(gun)?fire[sd]?"}},
        ]},
        {"label": "SITUATION", "id": "Gunfire", "pattern": [
            {"LOWER": {"REGEX": "^gunshots?"}},
        ]},
        {"label": "SITUATION", "id": "Gunfire", "pattern": [
            {"LOWER": {"REGEX": "^gunfire[sd]?"}},
        ]},
        {"label": "SITUATION", "id": "Gunfire", "pattern": [
            {"LOWER": {"REGEX": "^shootings?"}},
        ]},

        {"label": "SITUATION", "id": "Police Activity", "pattern": [
            {"LEMMA": "police"},
            {"LEMMA": "activity"},
        ]},
        {"label": "SITUATION", "id": "Police Activity", "pattern": [
            {"LEMMA": {"IN": ["officer", "trooper"]}},
            {"LEMMA": {"IN": ["down", "shoot", "kill"]}},
        ]},
        {"label": "SITUATION", "id": "Police Activity", "pattern": [
            {"LEMMA": {"IN": ["have", "be"]}},
            {"LEMMA": {"IN": ["down", "shoot", "kill"]}},
        ]},

    ]
    ruler.add_patterns(patterns)
    nlp.add_pipe(ruler)
    # if not os.path.isdir(model_dir):
    #    print("Creating directory", model_dir)
    #    os.mkdir(model_dir)
    # nlp.to_disk(model_dir)
    #print("Saved model to", model_dir)

    #print("Loading model from", model_dir)
    #nlp2 = spacy.load(model_dir)

    result = ''
    score = 0
    for status in searchRequest['statuses']:
        sentence = status['text']
        result += "Raw tweet text: " + sentence + " "
        #detectedSituation = False
        doc = nlp(sentence)
        for ent in doc.ents:
            #print(ent.text, ent.start_char, ent.end_char, ent.label_)
            if ent.label_ == "SITUATION":
                result += "SITUATION: " + ent.text  # + ": " + ent.ent_id_
                # string +=
                result += ", "
                score += 1
                if status['user']['verified']:
                    score += 4
    # print(string)
    result += "Score for this location: " + str(score) + ". "
    if score >= 5:
        result += "This result WILL be included in In The Know results."
    return json.dumps({"rawData": result})


def explain(request):
    # Use the base model from spaCy
    nlp = spacy.load('en_core_web_sm')
    #ruler = spacy.pipeline.EntityRuler(nlp)

    sentence = "A Nevada Highway Patrol trooper has been shot and killed during a confrontation early Friday morning near Ely."

    result = ''
    doc = nlp(sentence)
    for token in doc:
        print(token.text, token.lemma_, token.pos_, token.tag_, token.dep_,
              token.shape_, token.is_alpha, token.is_stop)
    # print(string)
    return "Analyzed " + sentence


# This function will NOT work on the server because files become read-only.
# This is only if I need to make significant modifications to the base model.
def train(request):
    # load
    nlp = spacy.load(model_dir)

    # perform modifications

    # save
    nlp.to_disk(model_dir)
