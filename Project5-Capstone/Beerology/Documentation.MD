## Scraping Data

## Pre-Processing

### Extracting Reviews

### Spellcheck
Remove empty strings  
Recode unicode?  
Retain alphanumeric (unicode included) and '  
Check for misspellings versus American English, French, and German  
Run initial spell-check:  
manually detect and include a list of common beer terms to prevent detection as misspellings  
Run second spell-check  
Replace misspelled words in corpus  
split words that are two words again in list, so each element is still retained as one word  
do nltk again to remove stopwords  

Simplifying assumptions: we will not do POS tagging to differentiate between words like address(n) and address(v).  
Simplifying assumptions: monograms only for now  
