import spacy



def hello(request):
    #spacy.cli.download('en_core_web_sm')
    nlp = spacy.load('en_core_web_sm')
    sentence = "Breaking: Mass shooting in San Diego, police have blocked off the area between Grand and the 163."
    doc = nlp(sentence)
    string = ''
    for ent in doc.ents: 
        #print(ent.text, ent.start_char, ent.end_char, ent.label_)
        string += ent.text + " " + ent.label_ + ", "
    return string