import spacy
import os
from twitter import *
from dotenv import load_dotenv
import json
import pandas as pd
load_dotenv()

model_dir = './models'
score_threshold = 5


def get_situations(request):
    # Use the base model from spaCy
    nlp = spacy.load('en_core_web_sm')
    ruler = spacy.pipeline.EntityRuler(nlp)

    twitter = Twitter(auth=OAuth2(
        bearer_token=os.environ.get('TWITTER_ACCESS_TOKEN')))

    lat = 40.8324
    long = -115.7631  # Elko

    # trendsResult = (twitter.trends.closest(lat=lat, long=long))[0]
    # placeName = trendsResult['name']
    # print('Place name:', placeName)

    # instead of using trends API since it has a smaller rate limit
    request_args = request.args
    if request_args and 'loc' in request_args:
        placeName = request_args['loc']
    else:
        placeName = "Elko"

    searchRequest = twitter.search.tweets(q=placeName, lang="en", count=50)

    # searchText = "sampletext"
    # with open('search.txt', 'r') as searchFile:
    #     searchText = searchFile.read()

    # searchRequest = {  # Sample search request
    #     "statuses": [
    #         {
    #             "text": searchText,
    #             "user": {"verified": True}
    #         }
    #     ]
    # }

    # Add "situation" patterns
    patterns = dict()
    with open('patterns.json', 'r') as patternfile:
        patterns = json.load(patternfile)['patterns']

    ruler.add_patterns(patterns)
    nlp.add_pipe(ruler)

    result = ''
    score = 0
    situations = dict()
    locations = dict()
    locCount = 0
    #keyStatuses = []
    for status in searchRequest['statuses']:
        sentence = status['text']
        #result += "Raw tweet text: " + sentence + " "
        detectedSituation = False
        #situationsInThisStatus = dict()
        #locationsInThisStatus = dict()
        doc = nlp(sentence)
        #dataFrame = pd.DataFrame.from_dict(data=doc.ents)
        #labels = dataFrame['label_']

        # First determine if this status contains a situation
        for ent in doc.ents:
            # print(ent.text, ent.start_char, ent.end_char, ent.label_)
            if ent.label_ == "SITUATION":
                detectedSituation = True
                break

        # if it has a situation, add all situations and geographical locations
        if detectedSituation:
            score += 1
            if status['user']['verified']:
                score += 4
            for ent in doc.ents:
                if ent.label_ == "SITUATION":
                    situations[ent.ent_id_] = situations.get(
                        ent.ent_id_, 0) + 1
                    # result += "SITUATION: " + ent.text  # + ": " + ent.ent_id_
                    #result += ", "
                elif ent.label_ == "GPE":
                    locCount += 1
                    ent_text_lower = str.lower(ent.text)
                    #print("ID: " + ent.ent_id_ + ", text: " + str.lower(ent.text))
                    locations[ent_text_lower] = locations.get(
                        ent_text_lower, 0) + 1
        # keyStatuses.append(status)

    print("Score for this location: " + str(score) + ". ")
    if score >= 5:
        print("This result WILL be included in the returned data.")

        # Get the most prominent situation type.
        print('All situations detected:')
        print(situations)
        sortedSituations = sorted(
            situations.items(), key=lambda kv: kv[1], reverse=True)
        # For now, assume there is one dominant situation.
        situationName = sortedSituations[0][0]
        print('Name of situation: ' + situationName)
        print('All locations detected:')
        print(locations)
        sortedLocations = sorted(
            locations.items(), key=lambda kv: kv[1], reverse=True)

        # Get frequency of each location and build JSON
        situationsList = list()
        locationsList = list()
        for loc in sortedLocations:
            frequency = loc[1] / locCount
            locationsList.append({'name': loc[0], 'frequency': frequency})
        
        # Only using one dominant situation for now
        situationsList.append({'type': situationName, 'locations': locationsList})

        # Final JSON construction
        result = {'situations': situationsList}

    return json.dumps(result)


def explain(request):
    # Use the base model from spaCy
    nlp = spacy.load('en_core_web_sm')
    # ruler = spacy.pipeline.EntityRuler(nlp)

    sentence = "RT @MichelleWilli7: Subject is in custody. Elko County SWAT has custody of suspect. There are explosives in the vehicle. We are gonna nee"

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

    # if not os.path.isdir(model_dir):
    #    print("Creating directory", model_dir)
    #    os.mkdir(model_dir)
    # nlp.to_disk(model_dir)
    # print("Saved model to", model_dir)

    # print("Loading model from", model_dir)
    # nlp2 = spacy.load(model_dir)

    # perform modifications

    # save
    nlp.to_disk(model_dir)
