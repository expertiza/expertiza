=begin
If negative words were found and a neg. descriptor is seen => (-)(-) = (+)
public static String[] NEGATIVE_DESCRIPTORS = new String[4879];
=end
NEGATIVE_DESCRIPTORS = [
      #negated phrases (topical words I spotted in text)
      "NOTHING", "nowhere", "scarcely", "scarce", "zero", "drawback",
          "barely", "hardly", "deny", "refuse", "fail", "failed",
          "without", "ambiguous", "ambiguity", "neither", "empty",
        "deviation", "lacks", "lack", "lacking", "lacked", "abrupt", "abruptly", "somewhat", "copied", "copy",
        "overbalanced", "ambiguous", "missing", "poor",
        "negative", "negatively", "underrepresented", "duplication", "wrong", "mistake", "mistakes","duplications",
        "duplicate", "duplicated", "duplicating", "avoids", "messy", "deleted", "cumbersome", "strange",
        "strangely", "misspell", "misspelling", "misspellings", "misspelt", "verbose", "confuse", "confusion", "confusing",
        "confused", "confuses", "trivial", "triviality", "typo", "typos", "somewhat", "concerns", "concern",
        "barring", "overuse", "repitition", "useless", "biased", "rushed", "absent", "wordy", "bad", "less", 
        "unclear", "difficult", "vague", "briefly", "hard", "broken","replicate","replicated", "digress", "clutter",
        "cluttered", "inadequate", "deviation", "contrived", "contrive", "horrid", "trouble","uneven", "unevenly", "alot",
        "incorrect"]
=begin
  SENTENCE CLAUSE OR PHRASE FOLLOWING THESE WORDS CARRY A NEGATIVE MEANING (EITHER SUBTLE OR OVERT)
=end
NEGATED_WORDS = ["not", "n't", "WON'T", "DON'T", "DIDN'T", 
        "DOESN'T", "WOULDN'T", "COULDN'T", "SHOULDN'T", "WASN'T", 
        "WEREN'T", "AREN'T", "ISN'T", "HAVEN'T", "HASN'T", "HADN'T",  "NOBODY",  
        "CAN'T","SHALLN'T", "MUSTN'T", "AIN'T", "cannot",        
        #without the apostrophe
        "cant", "dont", "wont","isnt","hasnt", "hadnt", "havent","arent", "werent", "wouldnt",
        "didnt", "couldnt", "shouldnt", "mustnt", "shallnt",        
        #other words that indicate negations (negative quantifiers)
        "NO", "NEVER", "NONE"]
          
NEGATIVE_PHRASES = ["too concise",
    "taken from", "been removed", "too long", "off topic",
    "too short", "run on", "too much", "been directly", "similar to",
    "at odds", "grammatical errors", "grammatical error", "available online",
    "make up", "made up", "crammed up"]
    
SUGGESTIVE_WORDS = ["would", "could", "should",
    "maybe", "perhaps", "might", "suggest", "suggests", "suggested", "advise", "advice","could've", "would've",
    "should've", "might've", "may", #"will", "better", "can"
    #when they provide sample examples
    "eg",
    #typos or colloqial
     "I'd", "We'd", "they'd", "you'd"]

#suggestive phrases
SUGGESTIVE_PHRASES = ["for example","try adding", "instead of", #(explaining what isnt good and what potentially could be)
    "little more", "try to", "need more", "needs to", "need to", "more detail",
    "can be", "was expecting", "am expecting", "is required"]
    
