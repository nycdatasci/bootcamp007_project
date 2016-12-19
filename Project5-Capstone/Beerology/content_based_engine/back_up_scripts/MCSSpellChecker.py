# Spell Checker using Microsoft Cognitive Services API
# Takes in a nested list of words for each review and
# replaces misspelled words.
# Outputs a nested list of words in a pickle.
# API limited to 5000 calls/month and 7 calls/minute,
# 10,000 characters per call on free trial.
# Written by LC 12/08/16 for NYCDSA Beer Recommendation Project

import requests
import ast
import re
import time
import pickle

# vals to pass onto API
header_vals = {'Content-Type': 'application/octet-stream', 
           'Ocp-Apim-Subscription-Key': '015913ba182b4acaa5af703529fa7f81'}
url_link = 'https://api.cognitive.microsoft.com/bing/v5.0/spellcheck/?mode=proof'



def spellCheckMCS(text, headers, url) :
    """Prints out misspelled words and suggested fixes.
    """
    params = {
        # Request parameters
        'text': text,
    }
    print text
    
    r = requests.post(url, params = params, headers=headers)
    misspellings = ast.literal_eval(r.content) # content is a dictionary in a string
    print r.content

    for ms in misspellings['flaggedTokens']: 
        print ms['token'], ms['offset']
        text_edited[ms['offset']]
        for s in ms['suggestions']:
            print s

def spellCheckMCSrepl(text, headers, url) :
    """Replaces misspelled words with the most highly suggested word.

    Returns:
        A nested list per original input to module.
    """


    params = {
        # Request parameters
        'text': text,
    }
    # print text
    text_edited = text.split(' ')
    spaces = [i for (i,w) in enumerate(text) if w == ' ']
    edit_list = []
    r = requests.post(url, params = params, headers=headers)
    misspellings = ast.literal_eval(r.content)  # it's a dictionary in a string
    # print r.content

    for ms in misspellings['flaggedTokens']:  # works if empty b/c it doesnt run  
        edit_list.append((ms['offset'], ms['suggestions'][0]['suggestion']))

    # to swap out corrected word, we find the nth space right after the word in the string.
    # this corresonds to the index in the list.
    pos = 0
    for i, suggest in edit_list:
        # itertools?
        while(i > spaces[pos]):
            pos +=1
            if i < spaces[pos]:
                text_edited[pos] = suggest

    string_text_edited =  ' '.join(text_edited)
    
    return [word.split(' ') for word in string_text_edited[:-2].split('  ')] # -2 to not count last '  '


# start here
nested_list = [['the','graet','car'], ['the', 'blck', 'fontain'], ['is beautiful']]
# print nested_list
string_words = ''
nchar = 0
ncalls = 0
fully_edited_list = []

# send string in chunks up to 10,000 chars
for ls in nested_list:
    excerpt = ' '.join(ls) + '  ' # split by '  ' later and to not confuse the spell checker
    if nchar + len(excerpt) > 10000:

        ncalls += 1
        if ncalls > 7:
            time.sleep(60)
            ncalls = 0
        fully_edited_list.extend(spellCheckMCSrepl(string_words, header_vals, url_link))
        string_words = ''
        nchar = 0


    string_words += excerpt
    nchar += len(excerpt)

# remaining words in queue
if string_words != '':
    fully_edited_list.extend(spellCheckMCSrepl(string_words, header_vals, url_link))


with open("spellchecked.pickle", "wb") as f:
    pickle.dump(fully_edited_list, f)
    
# shelved; for file input. Would have to change code to handle list instead of nested list.
#with f.open('wordlist.txt', 'r') as wordlist: 
    #string_words = ''
    #nchar = 0
    # 10,000 character limit
    # assume tuple
    '''
    for word, count in wordlist:
        if nchar + len(word) > 10000:
            #spellCheckMCS(string_words)
        else:
            string_words += word
            nchar += len(word)
    
if string_words != '':
    spellCheckMCS(string_words, header_vals, url_link)
'''




