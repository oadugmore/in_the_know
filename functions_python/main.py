import spacy
import os

model_dir = './models'

def hello(request):
    # use the base model from spaCy
    nlp = spacy.load('en_core_web_sm')
    ruler = spacy.pipeline.EntityRuler(nlp)

    patterns = [
        { "label": "SITUATION", "pattern": [{"LOWER": {"REGEX": "^(gun)?shots?"}}, {"LOWER": {"REGEX": "^(gun)?fire[sd]?"}}], "id": "Gunfire"},
        { "label": "SITUATION", "pattern": [{"LOWER": {"REGEX": "^gunshots?"}}], "id": "Gunfire"},
        { "label": "SITUATION", "pattern": [{"LOWER": {"REGEX": "^gunfire[sd]?"}}], "id": "Gunfire"},
        { "label": "SITUATION", "pattern": [{"LOWER": {"REGEX": "^shootings?"}}], "id": "Gunfire"},

        { "label": "SITUATION", "pattern": [{"LOWER": "^police"}, {"LOWER": "^activit(y|ies)"}], "id": "Police Activity"},
        { "label": "SITUATION", "pattern": [{"LOWER": {"REGEX": "^(gun)?shots?"}}, {"LOWER": {"REGEX": "^(gun)?fire[sd]?"}}], "id": "Police Activity"},
        { "label": "SITUATION", "pattern": [{"LOWER": {"REGEX": "^officers?"}}, {"LOWER": {"REGEX": "^down$"}}], "id": "Police Activity"},
    ]

    ruler.add_patterns(patterns)
    nlp.add_pipe(ruler)
    #if not os.path.isdir(model_dir):
    #    print("Creating directory", model_dir)
    #    os.mkdir(model_dir)
    #nlp.to_disk(model_dir)
    #print("Saved model to", model_dir)

    #print("Loading model from", model_dir)
    #nlp2 = spacy.load(model_dir)

    #sentence = "Breaking: police activity reported at 11:02 AM in San Diego, the area between Grand Avenue and the CA-163 has been blocked off by SDPD."
    sentence = "San Diego police respond to shots fired in Hillcrest. Avoid the area due to police activity"
    #sentence = "Please avoid the area of 4000 Boston Ave. due to police activity. The media staging location is at 40th and Z Street. Check back for further updates."
    doc = nlp(sentence)
    string = ''
    for ent in doc.ents: 
        #print(ent.text, ent.start_char, ent.end_char, ent.label_)
        string += ent.text + " " + ent.label_
        if ent.label_ == "SITUATION":
            string += ": " + ent.ent_id_
        string += ", "
    #print(string)
    return string

def blank_model(request):
    training_data = [
        (
            "breaking: police activity reported at 11:02 AM in san diego, the area between grand avenue and the ca-163 has been blocked off by sdpd.",
            {
                "heads": [0, 0, 2, 2, 2, 3, ],
                "deps": ["-", "-", "ATTRIBUTE", "SITUATION", "-", "-", "TIME", "-", "TIME" "TIME", "-" "LOCATION"]
            }
        )
    ]

    nlp = spacy.blank('en')
    test_model_dir = './models/test_model'

# This function will NOT work on the server because files become read-only.
def train(request):
    # load
    nlp = spacy.load(model_dir)

    # save
    nlp.to_disk(model_dir)

