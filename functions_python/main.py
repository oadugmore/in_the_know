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

    #searchRequest = twitter.search.tweets(q=placeName, lang="en", count=50)
    searchText = "sampletext"
    with open('search.txt', 'r') as searchFile:
        searchText = searchFile.read()

    searchRequest = {  # Sample search request
        "statuses": [
            {
                "text": searchText,
                "user": {"verified": False}
            }
        ]
    }

    # Add "situation" patterns
    patterns = {}
    with open('patterns.json', 'r') as patternfile:
        patterns = json.load(patternfile)['patterns']
    
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
