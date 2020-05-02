from twitter import Twitter, OAuth2
import spacy
import json
import os
from dotenv import load_dotenv

# load global data
load_dotenv()
model_dir = './models'
nlp = spacy.load(model_dir)
SCORE_THRESHOLD = 5
TWEET_COUNT = 50

# establish connection to Twitter
twitter = Twitter(auth=OAuth2(
    bearer_token=os.environ.get('TWITTER_ACCESS_TOKEN')))
print('Connected to Twitter.')


def get_situations(request):
    request_args = request.args
    if request_args and 'q' in request_args:
        query = request_args['q']
    else:
        query = "Elko"

    search_result = twitter_query(query, 'en')
    return json.dumps(search_result)


def twitter_query(search_query, lang):
    twitter_response = twitter.search.tweets(
        q=search_query, lang=lang, count=TWEET_COUNT)

    result = {'situations': []}
    # result = ''
    score = 0
    situations = dict()
    locations = dict()
    locCount = 0
    key_statuses = []
    for status in twitter_response['statuses']:
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
            key_statuses.append(status)
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
                    #print("Entity text: " + str.lower(ent.text))
                    locations[ent_text_lower] = locations.get(
                        ent_text_lower, 0) + 1
        # keyStatuses.append(status)

    print("Score for this location: " + str(score) + ". ")
    if score >= 5:
        print("This result WILL be included in the returned data.")

        # Get the most prominent situation type.
        #print('All situations detected:')
        # print(situations)
        sortedSituations = sorted(
            situations.items(), key=lambda kv: kv[1], reverse=True)
        # For now, assume there is one dominant situation.
        situationName = sortedSituations[0][0]
        #print('Name of situation: ' + situationName)
        #print('All locations detected:')
        # print(locations)
        sortedLocations = sorted(
            locations.items(), key=lambda kv: kv[1], reverse=True)

        # Get frequency of each location and build JSON
        situationsList = list()
        locationsList = list()
        for loc in sortedLocations:
            frequency = loc[1] / locCount
            locationsList.append({'name': loc[0], 'frequency': frequency})

        # Only using one dominant situation for now
        situationsList.append(
            {'type': situationName, 'locations': locationsList, 'statuses': key_statuses})

        # Final JSON construction
        result['situations'] = situationsList
        # result = {'situations': situationsList}
    else:
        print("This result did not meet the threshold to be included in the returned data.")

    return result


def explain(request):
    sentence = "RT @MichelleWilli7: Subject is in custody. Elko County SWAT has custody of suspect. There are explosives in the vehicle. We are gonna nee"

    result = ''
    doc = nlp(sentence)
    for token in doc:
        print(token.text, token.lemma_, token.pos_, token.tag_, token.dep_,
              token.shape_, token.is_alpha, token.is_stop)
    # print(string)
    return "Analyzed " + sentence

# This function will NOT work on the server because files become read-only.
# This is only for training the model offline.
def train():
    # load
    nlp_train = spacy.load('en_core_web_sm')

    if not os.path.isdir(model_dir):
        print("Creating directory", model_dir)
        os.mkdir(model_dir)

    # perform modifications

    # Add "situation" patterns
    ruler = spacy.pipeline.EntityRuler(nlp_train)
    patterns = dict()
    with open('patterns.json', 'r') as patternfile:
        patterns = json.load(patternfile)['patterns']

    ruler.add_patterns(patterns)
    nlp_train.add_pipe(ruler)

    # save
    nlp_train.to_disk(model_dir)
    print("Saved model to", model_dir)


if __name__ == "__main__":
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

    twitter_query('police activity', 'en')
    #train()
