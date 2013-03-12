require 'automated_metareview/vertex'
require 'automated_metareview/constants'

class WordnetBasedSimilarity
  attr_accessor :match, :count
  @@posTagger = EngTagger.new  
  def compare_strings(reviewVertex, submVertex, speller)
    #must fix this to something that is local to the app
    # WordNet::WordNetDB.path = "/usr/local/WordNet-3.0"
    # WordNet::WordNetDB.path = "/usr/local/Cellar/wordNet/3.0"
    review = reviewVertex.name
    submission = submVertex.name
    reviewState = reviewVertex.state
    submState = submVertex.state
    
    #puts("@@@@@@@@@ Comparing Vertices:: #{review} and #{submission} :: RevState:: #{reviewState} and SubmState:: #{submState}");
    @match = 0
    @count = 0
    
    reviewPOS = ""
    submPOS = ""
     
    #checking for exact matches between the tokens
    if(review.casecmp(submission) == 0) # and !is_frequent_word(reviewVertex.name) - removing this condition else, it returns a NOMATCH although the frequent words are equal and this negatively impacts the total match value
      # puts("Review vertex types #{reviewVertex.type} && #{submVertex.type}")   
      if(reviewState.equal?(submState))
        @match = @match + EXACT
      elsif(!reviewState.equal?(submState))
        @match = @match + NEGEXACT
      end
      return @match
    end   
    
    #stokRev = review.split(" ")
    #stokSub = submission.split(" ") #should've been inside when doing n * n comparison
    
    #iterating through review tokens
    #for i in (0..stokRev.length-1)
      #if either of the tokens is null
      #if(stokRev[i].nil?)
       # next #continue with the next token
      #end
      revToken = review #stokRev[i].downcase()
      if(reviewPOS.empty?)#do not reset POS for every new token, it changes the POS of the vertex e.g. like has diff POS for vertices "like"(n) and "would like"(v)
        reviewPOS = determine_POS(reviewVertex).strip
      end
      
      # puts("*** RevToken:: #{revToken} ::Review POS:: #{reviewPOS} class #{reviewPOS.class}")
      if(revToken.equal?("n't"))
        revToken = "not"
        # puts("replacing n't")
      end
      
      #if the review token is a frequent word, continue
      if(is_frequent_word(revToken))
        # puts("Skipping frequent review token .. #{revToken}")
        return NOMATCH #next #equivalent of the "continue"
      end
      
      #fetching synonyms, hypernyms, hyponyms etc. for the review token       
      revStem = find_stem_word(revToken, speller)     
      #fetching all the relations
      review_relations = get_relations_for_review_submission_tokens(revToken, revStem, reviewPOS)
      #setting the values in specific array variables
      revGloss = review_relations[0]
      revSyn =review_relations[1]
      revHyper = review_relations[2]
      revHypo = review_relations[3]
      revAnt = review_relations[4]
      
      # puts "reviewStem:: #{revStem} .. #{revStem.class}" 
      # puts "reviewGloss:: #{revGloss} .. #{revGloss.class}"  
      # puts "reviewSynonyms:: #{revSyn} .. #{revSyn.class}"
      # puts "reviewHypernyms:: #{revHyper} .. #{revHyper.class}"
      # puts "reviewHyponyms:: #{revHypo} .. #{revHypo.class}"
      # puts "reviewAntonyms:: #{revAnt} .. #{revAnt.class}"
        
      #stokSub = submission.split(" ")
      #iterating through submission tokens
      #for j in (0..stokSub.length-1)
      
        #if(stokSub[j].nil?)
          #next
        #end
        
        subToken = submission #stokSub[j].downcase()
        if(submPOS.empty?)#do not reset POS for every new token, it changes the POS of the vertex e.g. like has diff POS for vertices "like"(n) and "would like"(v)
          submPOS = determine_POS(submVertex).strip
        end
        
        # puts("*** SubToken:: #{subToken} ::Review POS:: #{submPOS}")
        if(subToken.equal?("n't"))
          subToken = "not"
          # puts("replacing n't")
        end
        
        #if the review token is a frequent word, continue
        if(is_frequent_word(subToken))
          # puts("Skipping frequent subtoken .. #{subToken}")
          return NOMATCH #equivalent of the "continue"
        end
                    
        #fetching synonyms, hypernyms, hyponyms etc. for the submission token
        submStem = find_stem_word(subToken, speller)
        subm_relations = get_relations_for_review_submission_tokens(subToken, submStem, submPOS)
        submGloss = subm_relations[0]
        submSyn =subm_relations[1]
        submHyper = subm_relations[2]
        submHypo = subm_relations[3]
        submAnt = subm_relations[4]  
        # puts "submStem:: #{submStem}"        
        # puts "submGloss:: #{submGloss}"
        # puts "submSynonyms:: #{submSyn}"
        # puts "submHypernyms:: #{submHyper}"
        # puts "submHyponyms:: #{submHypo}"
        # puts "submAntonyms:: #{submAnt}" 
          
        #------------------------------------------
        #checks are ordered from BEST to LEAST degree of semantic relatedness
        #*****exact matches 
        # puts "@match #{@match} reviewState #{reviewState} submState #{submState} reviewPOS #{reviewPOS} submPOS #{submPOS}"  
        # puts "reviewState.equal?(submState) #{reviewState.equal?(submState)}"
        # puts "reviewPOS.equal?(submPOS) #{reviewPOS == submPOS}"     
        if(subToken.casecmp(revToken) == 0 or submStem.casecmp(revStem) == 0) #EXACT MATCH (submission.toLowerCase().equals(review.toLowerCase()))
          # puts("exact match for #{revToken} & #{subToken} or #{submStem} and #{revStem}")
          if(reviewState.equal?(submState))
            @match = @match + EXACT
          elsif(!reviewState.equal?(submState))
            @match = @match + NEGEXACT
          end
          @count+=1
          return @match #next #skip all remaining checks
        end #end of if condition checking for exact matches
        #------------------------------------------
        #*****For Synonyms
        #if the method returns 'true' it indicates a synonym match of some kind was found and the remaining checks can be skipped
        if(check_match(revToken, subToken, revSyn, submSyn, revStem, submStem, reviewState, submState, SYNONYM, ANTONYM))
          return @match #next
        end
        #------------------------------------------
        #ANTONYMS
        if(check_match(revToken, subToken, revAnt, submAnt, revStem, submStem, reviewState, submState, ANTONYM, SYNONYM))
          return @match #next
        end
        #------------------------------------------
        #*****For Hypernyms
        if(check_match(revToken, subToken, revHyper, submHyper, revStem, submStem, reviewState, submState, HYPERNYM, NEGHYPERNYM))
          return @match #next
        end
        #------------------------------------------   
        #*****For Hyponyms
        if(check_match(revToken, subToken, revHypo, submHypo, revStem, submStem, reviewState, submState, HYPONYM, NEGHYPONYM))
          return @match #next
        end
         
        #overlap across definitions   
        # checking if overlaps exist across review and submission tokens' defintions or if either defintiions contains the review
        # or submission token or stem.
        # puts "#{extract_definition(revGloss)[0]} .. extract_definition(revGloss)[0] #{extract_definition(revGloss)[0][0].class}"
        # puts "!revGloss #{!revGloss} .. revGloss.class #{revGloss.class}.. revGloss[0].include?(subToken) #{revGloss[0].include?(subToken)}"
        # rev_def = extract_definition(revGloss)
        # sub_def = extract_definition(submGloss) 
        #(!revGloss.nil? and !submGloss.nil? and overlap(revGloss, submGloss, speller) > 0) or
        if((!revGloss.nil? and !revGloss[0].nil? and !subToken.nil? and !submStem.nil? and (revGloss[0].include?(subToken) or revGloss[0].include?(submStem))) or 
          (!submGloss.nil? and !submGloss[0].nil? and !revToken.nil? and !revStem.nil? and (submGloss[0].include?(revToken) or submGloss[0].include?(revStem))))
          if(reviewState == submState)
            @match = @match + OVERLAPDEFIN
          elsif(reviewState != submState)
            @match = @match + NEGOVERLAPDEFIN
          end
          @count+=1
          return @match #next
        end
        
        #no match found!
        # puts "No Match found!"
        @match = @match + NOMATCH
        @count+=1
      #end #end of the for loop for submission tokens 
    #end #end of the for loop for review tokens
    
    if(@count > 0)
      # puts ("Match: #{@match} Count:: #{@count}")
      result = (@match.to_f/@count.to_f).round
      # puts("@@@@@@@@@ Returning Value: #{result}")
      return result #an average of the matches found
    end
    # puts("@@@@@@@@@ Returning NOMATCH")
    return NOMATCH
    
  end #end of compareStrings method
  
#------------------------------------------------------------------------------
=begin
 This method fetches the synonyms, hypernyms, hyponyms and other relations for the 'token' and its stem 'stem'.
 This is done for both review and submission tokens/stems.
 It returns a double dimensional array, where each element is an array of synonyms, hypernyms etc. 
=end

def get_relations_for_review_submission_tokens(token, stem, pos)
  # puts "@@@@ Inside get_relations_for_review_submission_tokens"
  relations = Array.new
  lemmas = WordNet::WordNetDB.find(token)
  if(lemmas.nil?)
    lemmas = WordNet::WordNetDB.find(stem) 
  end
  #select the lemma corresponding to the token's POS
  lemma = ""
  lemmas.each do |l|
    # puts "lemma's POS :: #{l.pos} and POS :: #{pos}"
    if(l.pos == pos)
      lemma = l
      break
    end  
  end
      
  def_arr = Array.new
  syn_arr = Array.new
  hyper_arr = Array.new
  hypo_arr = Array.new
  anto_arr = Array.new
        
  #if selected reviewLemma is not nil or empty
  if(!lemma.nil? and lemma != "" and !lemma.synsets.nil?)      
    #creating arrays of all the values for synonyms, hyponyms etc. for the review token
    for g in 0..lemma.synsets.length - 1
      #fetching the first review synset
      lemma_synset = lemma.synsets[g]
      
      #definitions
      if(!lemma_synset.gloss.nil?)
        #puts "lemma_synset.gloss.class #{lemma_synset.gloss.class}"
        if(def_arr[0].nil?)
          def_arr << extract_definition(lemma_synset.gloss)
        else
          def_arr[0] = def_arr[0] + " " + extract_definition(lemma_synset.gloss)
        end
      else
        def_arr << nil
      end
      
      #looking for all relations synonym, hypernym, hyponym etc. from among this synset
      #synonyms
      begin #error handling for lemmas's without synsets that throw errors! (likely due to the dictionary file we are using)
        lemmaSyns = lemma_synset.get_relation("&")
        if(!lemmaSyns.nil? and lemmaSyns.length != 0)
          # puts "lemmaSyns.length #{lemmaSyns.length}"
          #for each synset get the values and add them to the array
          for h in 0..lemmaSyns.length - 1
            # puts "lemmaSyns[h].words.class #{lemmaSyns[h].words.class}"
            syn_arr = syn_arr + lemmaSyns[h].words
            # puts "**** syn_arr #{syn_arr}"
          end
        else
          syn_arr << nil #setting nil when no synset match is found for a particular type of relation
        end
      rescue
        syn_arr << nil
      end
      
      #hypernyms
      begin
        lemmaHypers = lemma_synset.get_relation("@")#hypernym.words
        if(!lemmaHypers.nil? and lemmaHypers.length != 0)
          #for each synset get the values and add them to the array
          for h in 0..lemmaHypers.length - 1
            #puts "lemmaHypers[h].words.class #{lemmaHypers[h].words.class}"
            hyper_arr = hyper_arr + lemmaHypers[h].words
          end
        else
          hyper_arr << nil
        end
      rescue
        hyper_arr << nil
      end
      
      #hyponyms
      begin
        lemmaHypos = lemma_synset.get_relation("~")#hyponym
        if(!lemmaHypos.nil? and lemmaHypos.length != 0)
          #for each synset get the values and add them to the array
          for h in 0..lemmaHypos.length - 1
            hypo_arr = hypo_arr + lemmaHypos[h].words
          end
        else
          hypo_arr << nil
        end
      rescue
        hypo_arr << nil
      end
      
      #antonyms
      begin
        lemmaAnts = lemma_synset.get_relation("!")
        if(!lemmaAnts.nil? and lemmaAnts.length != 0)
          #for each synset get the values and add them to the array
          for h in 0..lemmaAnts.length - 1
            anto_arr = anto_arr + lemmaAnts[h].words
          end
        else
          anto_arr << nil
        end
      rescue
        anto_arr << nil
      end         
    end #end of the for loop for g  
  end #end of checking if the lemma is nil or empty

  #setting the array elements before returning the array
  relations << def_arr
  relations << syn_arr
  relations << hyper_arr
  relations << hypo_arr
  relations << anto_arr
  return relations
end

#------------------------------------------------------------------------------
=begin
 This method compares the submission and reviews' synonyms and antonyms with each others' tokens and stem values.
 The instance variables 'match' and 'count' are updated accordingly. 
=end
def check_match(rev_token, subm_token, rev_arr, subm_arr, rev_stem, subm_stem, rev_state, subm_state, match_type, non_match_type)
  flag = 0 #indicates if a match was found
  # puts("check_match between: #{rev_token} & #{subm_token} match_type #{match_type} and non_match_type #{non_match_type}")
  # puts "rev_arr #{rev_arr}"
  # puts "subm_arr #{subm_arr}"
  if((!rev_arr.nil? and (rev_arr.include?(subm_token) or rev_arr.include?(subm_stem))) or 
    (!subm_arr.nil? and (subm_arr.include?(rev_token) or subm_arr.include?(rev_stem))))          
    # puts("Match found between: #{rev_token} & #{subm_token}")
    flag = 1 #setting the flag to indicate that a match was found
    if(rev_state == subm_state)
      @match = @match + match_type
    elsif(rev_state != subm_state)
      @match = @match+ non_match_type
    end
    @count+=1
  end
  if(flag == 1)
    return true
  else
    return false
  end
end

#------------------------------------------------------------------------------

=begin
 determine_POS - method helps identify the POS tag (for the wordnet lexicon) for a certain word 
=end
def determine_POS(vert)
  str_pos = vert.pos_tag
  # puts("Inside determine_POS POS Tag:: #{str_pos}")
  if(str_pos.include?("CD") or str_pos.include?("NN") or str_pos.include?("PR") or str_pos.include?("IN") or str_pos.include?("EX") or str_pos.include?("WP"))
    pos = "n"#WordNet::Noun
  elsif(str_pos.include?("JJ"))
    pos = "a" #WordNet::Adjective
  elsif(str_pos.include?("TO") or str_pos.include?("VB") or str_pos.include?("MD"))
    pos = "v" #WordNet::Verb
  elsif(str_pos.include?("RB"))
    pos = "r" #WordNet::Adverb
  else
    pos = "n" #WordNet::Noun
  end
  return pos
end

#------------------------------------------------------------------------------     
=begin
  is_frequent_word - method checks to see if the given word is a frequent word
=end
def is_frequent_word(word)
  word.gsub!("(", "") #gsub replaces all occurrences of "(" and the exclamation point helps to do in-place substitution
  word.gsub!(")", "") #if the character doesn't exist, the function returns nil, which does not affect the existing variable
  word.gsub!("[", "")
  word.gsub!("]", "")
  word.gsub!("\"", "")

  if(FREQUENT_WORDS.include?(word))
    return true
  end

  if(CLOSED_CLASS_WORDS.include?(word))
    return true
  end  
  
  return false
end #end of is_frequent_word method
#------------------------------------------------------------------------------
=begin
  find_stem_word - stems the word and checks if the word is correctly spelt, else it will return a correctly spelled word as suggested by spellcheck
  It generated the nearest stem, since no context information is involved, the quality of the stems may not be great!
=end
def find_stem_word(word, speller)
  stem = word.stem
  correct = stem #initializing correct to the stem word
  #checkiing the stem word's spelling for correctness
  while(!speller.check(correct)) do
    if(!speller.suggest(correct).first.nil?)
      correct = speller.suggest(correct).first
    else
      #break out of the loop, else it will continue infinitely
      break #break out of the loop if the first correction was nil
    end
  end
  return correct
end #end of is_frequent_word method

#------------------------------------------------------------------------------

=begin
 This method is used to extract definitions for the words (since glossed contain definitions and examples!)
 glosses - string containing the gloss of the synset 
=end
def extract_definition(glosses)
  definitions = ""#[]
  #extracting examples from definitions
  temp = glosses
  tempList = temp.split(";")
  for i in 0..tempList.length - 1
    if(!tempList[i].include?('"'))
      if(definitions.empty?)
        definitions = tempList[i]
      else
        definitions = definitions +" "+ tempList[i]
      end
    end
  end
  #puts definitions
  return definitions
end
#------------------------------------------------------------------------------

def overlap(def1, def2, speller)
  instance = WordnetBasedSimilarity.new
  numOverlap = 0
  #only overlaps across the ALL definitions
  # puts "def1 #{def1}"
  # puts "def2 #{def2}"
  
  #iterating through def1's definitions
  for i in 0..def1.length-1
    if(!def1[i].nil?)
      #puts "def1[#{i}] #{def1[i]}"
      if( def1[i].include?("\""))
        def1[i].gsub!("\"", " ")
      end
      if(def1[i].include?(";"))
        def1[i] = def1[i][0..def1[i].index(";")]
      end
      #iterating through def2's definitions
      for j in 0..def2.length - 1   
        if(!def2[j].nil?)
          if(def2[j].include?(";"))
            def2[j] = def2[j][0..def2[j].index(";")]
          end
          #puts "def2[#{j}] #{def2[j]}"
          s1 = def1[i].split(" ")
          s1.each do |tok1|
            tok1stem = find_stem_word(tok1, speller)
            s2 = def2[j].split(" ")
            s2.each do |tok2|
              tok2stem = find_stem_word(tok2, speller)
              # puts "tok1 #{tok1} and tok2 #{tok2}"
              # puts "tok1stem #{tok1stem} and tok2stem #{tok2stem}"
              if((tok1.downcase == tok2.downcase or tok1stem.downcase == tok2stem.downcase) and 
                !instance.is_frequent_word(tok1) and !instance.is_frequent_word(tok1stem))
                # puts("**Overlap def/ex:: #{tok1} or #{tok1stem}")
                numOverlap+=1
              end
            end #end of s2 loop
          end #end of s1 loop
        end #end of def2[j][0] being null
      end #end of for loop for def2 - j
    end #end of if def1[i][0] being null
  end #end of for loop for def1 - i
  return numOverlap
end
#------------------------------------------------------------------------------
end #end of WordnetBasedSimilarity class