require 'automated_metareview/negations'
require 'automated_metareview/constants'

class SentenceState
  attr_accessor :broken_sentences
  def identify_sentence_state(str_with_pos_tags)
    # puts("**** Inside identify_sentence_state #{str_with_pos_tags}")
    #break the sentence at the co-ordinating conjunction
    num_conjunctions = break_at_coordinating_conjunctions(str_with_pos_tags)
    
    states_array = Array.new
    if(@broken_sentences == nil)
      states_array[0] = sentence_state(str_with_pos_tags)
    #identifying states for each of the sentence segments
    else
      for i in (0..num_conjunctions)
        if(!@broken_sentences[i].nil?)
          states_array[i] = sentence_state(@broken_sentences[i])
        end
      end
    end
    return states_array
  end #end of the methods
#------------------------------------------#------------------------------------------  
  def break_at_coordinating_conjunctions(str_with_pos_tags)
    st = str_with_pos_tags.split(" ")
    count = st.length
    counter = 0

    @broken_sentences = Array.new
    #if the sentence contains a co-ordinating conjunction
    if(str_with_pos_tags.include?("CC"))
      counter = 0
      temp = ""
      for i in (0..count-1)
        ps = st[i]
        if(!ps.nil? and ps.include?("CC"))
          @broken_sentences[counter] = temp #for "run/NN on/IN..."
          counter+=1
          temp = ps[0..ps.index("/")]
          #the CC or IN goes as part of the following sentence
        elsif (!ps.nil? and !ps.include?("CC"))
          temp = temp +" "+ ps[0..ps.index("/")]
        end
      end
      if(!temp.empty?) #setting the last sentence segment
        @broken_sentences[counter] = temp
        counter+=1
      end
    else
      @broken_sentences[counter] = str_with_pos_tags
      counter+=1
    end
    return counter
  end #end of the method
#------------------------------------------#------------------------------------------

  #Checking if the token is a negative token
  def sentence_state(str_with_pos_tags)
    state = POSITIVE
    #checking single tokens for negated words
    st = str_with_pos_tags.split(" ")
    count = st.length
    tokens = Array.new
    tagged_tokens = Array.new
    i = 0
    interim_noun_verb  = false #0 indicates no interim nouns or verbs
        
    #fetching all the tokens
    for k in (0..st.length-1)
      ps = st[k]
      #setting the tagged string
      tagged_tokens[i] = ps
      if(ps.include?("/"))
        ps = ps[0..ps.index("/")-1] 
      end
      #removing punctuations 
      if(ps.include?("."))
        tokens[i] = ps[0..ps.index(".")-1]
      elsif(ps.include?(","))
        tokens[i] = ps.gsub(",", "")
      elsif(ps.include?("!"))
        tokens[i] = ps.gsub("!", "")
      elsif(ps.include?(";"))
        tokens[i] = ps.gsub(";", "")
      else
        tokens[i] = ps
        i+=1
      end     
    end#end of the for loop
    
    #iterating through the tokens to determine state
    prev_negative_word =""
    for j  in (0..i-1)
      #checking type of the word
      #checking for negated words
      if(is_negative_word(tokens[j]) == NEGATED)  
        returned_type = NEGATIVE_WORD
      #checking for a negative descriptor (indirect indicators of negation)
      elsif(is_negative_descriptor(tokens[j]) == NEGATED)
        returned_type = NEGATIVE_DESCRIPTOR
      #2-gram phrases of negative phrases
      elsif(j+1 < count && !tokens[j].nil? && !tokens[j+1].nil? && 
        is_negative_phrase(tokens[j]+" "+tokens[j+1]) == NEGATED)
        returned_type = NEGATIVE_PHRASE
        j = j+1      
      #if suggestion word is found
      elsif(is_suggestive(tokens[j]) == SUGGESTIVE)
        returned_type = SUGGESTIVE
      #2-gram phrases suggestion phrases
      elsif(j+1 < count && !tokens[j].nil? && !tokens[j+1].nil? &&
         is_suggestive_phrase(tokens[j]+" "+tokens[j+1]) == SUGGESTIVE)
        returned_type = SUGGESTIVE
        j = j+1
      #else set to positive
      else
        returned_type = POSITIVE
      end
      
      #----------------------------------------------------------------------
      #comparing 'returnedType' with the existing STATE of the sentence clause
      #after returnedType is identified, check its state and compare it to the existing state
      #if present state is negative and an interim non-negative or non-suggestive word was found, set the flag to true
      if((state == NEGATIVE_WORD or state == NEGATIVE_DESCRIPTOR or state == NEGATIVE_PHRASE) and returned_type == POSITIVE)
        if(interim_noun_verb == false and (tagged_tokens[j].include?("NN") or tagged_tokens[j].include?("PR") or tagged_tokens[j].include?("VB") or tagged_tokens[j].include?("MD")))
          interim_noun_verb = true
        end
      end 
      
      if(state == POSITIVE and returned_type != POSITIVE)
        state = returned_type
      #when state is a negative word
      elsif(state == NEGATIVE_WORD) #previous state
        if(returned_type == NEGATIVE_WORD)
          #these words embellish the negation, so only if the previous word was not one of them you make it positive
          if(prev_negative_word.casecmp("NO") != 0 and prev_negative_word.casecmp("NEVER") != 0 and prev_negative_word.casecmp("NONE") != 0)
            state = POSITIVE #e.g: "not had no work..", "doesn't have no work..", "its not that it doesn't bother me..."
          else
            state = NEGATIVE_WORD #e.g: "no it doesn't help", "no there is no use for ..."
          end  
          interim_noun_verb = false #resetting         
        elsif(returned_type == NEGATIVE_DESCRIPTOR or returned_type == NEGATIVE_PHRASE)
          state = POSITIVE #e.g.: "not bad", "not taken from", "I don't want nothing", "no code duplication"// ["It couldn't be more confusing.."- anomaly we dont handle this for now!]
          interim_noun_verb = false #resetting
        elsif(returned_type == SUGGESTIVE)
          #e.g. " it is not too useful as people could...", what about this one?
          if(interim_noun_verb == true) #there are some words in between
            state = NEGATIVE_WORD
          else
            state = SUGGESTIVE #e.g.:"I do not(-) suggest(S) ..."
          end
          interim_noun_verb = false #resetting
        end
      #when state is a negative descriptor
      elsif(state == NEGATIVE_DESCRIPTOR)
        if(returned_type == NEGATIVE_WORD)
          if(interim_noun_verb == true)#there are some words in between
            state = NEGATIVE_WORD #e.g: "hard(-) to understand none(-) of the comments"
          else
            state = POSITIVE #e.g."He hardly not...."
          end
          interim_noun_verb = false #resetting
        elsif(returned_type == NEGATIVE_DESCRIPTOR)
          if(interim_noun_verb == true)#there are some words in between
            state = NEGATIVE_DESCRIPTOR #e.g:"there is barely any code duplication"
          else 
            state = POSITIVE #e.g."It is hardly confusing..", but what about "it is a little confusing.."
          end
          interim_noun_verb = false #resetting
        elsif(returned_type == NEGATIVE_PHRASE)
          if(interim_noun_verb == true)#there are some words in between
            state = NEGATIVE_PHRASE #e.g:"there is barely any code duplication"
          else 
            state = POSITIVE #e.g.:"it is hard and appears to be taken from"
          end
          interim_noun_verb = false #resetting
        elsif(returned_type == SUGGESTIVE)
          state = SUGGESTIVE #e.g.:"I hardly(-) suggested(S) ..."
          interim_noun_verb = false #resetting
        end
      #when state is a negative phrase
      elsif(state == NEGATIVE_PHRASE)
        if(returned_type == NEGATIVE_WORD)
          if(interim_noun_verb == true)#there are some words in between
            state = NEGATIVE_WORD #e.g."It is too short the text and doesn't"
          else
            state = POSITIVE #e.g."It is too short not to contain.."
          end
          interim_noun_verb = false #resetting
        elsif(returned_type == NEGATIVE_DESCRIPTOR)
          state = NEGATIVE_DESCRIPTOR #e.g."It is too short barely covering..."
          interim_noun_verb = false #resetting
        elsif(returned_type == NEGATIVE_PHRASE)
          state = NEGATIVE_PHRASE #e.g.:"it is too short, taken from ..."
          interim_noun_verb = false #resetting
        elsif(returned_type == SUGGESTIVE)
          state = SUGGESTIVE #e.g.:"I too short and I suggest ..."
          interim_noun_verb = false #resetting
        end
      #when state is suggestive
      elsif(state == SUGGESTIVE) #e.g.:"I might(S) not(-) suggest(S) ..."
        if(returned_type == NEGATIVE_DESCRIPTOR)
          state = NEGATIVE_DESCRIPTOR
        elsif(returned_type == NEGATIVE_PHRASE)
          state = NEGATIVE_PHRASE
        end
        #e.g.:"I suggest you don't.." -> suggestive
        interim_noun_verb = false #resetting
      end
      
      #setting the prevNegativeWord
      if(tokens[j].casecmp("NO") == 0 or tokens[j].casecmp("NEVER") == 0 or tokens[j].casecmp("NONE") == 0)
        prev_negative_word = tokens[j]
      end  
          
    end #end of for loop
    
    if(state == NEGATIVE_DESCRIPTOR or state == NEGATIVE_WORD or state == NEGATIVE_PHRASE)
      state = NEGATED
    end
    
    return state
  end
  
#------------------------------------------#------------------------------------------  

#Checking if the token is a negative token
def is_negative_word(word)
  not_negated = POSITIVE
  for i in (0..NEGATED_WORDS.length - 1)
    if(word.casecmp(NEGATED_WORDS[i]) == 0)
      not_negated =  NEGATED #indicates negation found
      break
    end
  end
  return not_negated
end
#------------------------------------------#------------------------------------------

#Checking if the token is a negative token
def is_negative_descriptor(word)
  not_negated = POSITIVE
  for i in (0..NEGATIVE_DESCRIPTORS.length - 1)
    if(word.casecmp(NEGATIVE_DESCRIPTORS[i]) == 0)
      not_negated =  NEGATED #indicates negation found
      break
    end  
  end
  return not_negated
end

#------------------------------------------#------------------------------------------    

#Checking if the phrase is negative
def is_negative_phrase(phrase)
  not_negated = POSITIVE
  for i in (0..NEGATIVE_PHRASES.length - 1)
    if(phrase.casecmp(NEGATIVE_PHRASES[i]) == 0)
      not_negated =  NEGATED #indicates negation found
      break
    end
  end
  return not_negated
end

#------------------------------------------#------------------------------------------    
#Checking if the token is a suggestive token
def is_suggestive(word)
  not_suggestive = POSITIVE
  #puts "inside is_suggestive for token:: #{word}"
  for i in (0..SUGGESTIVE_WORDS.length - 1)
    if(word.casecmp(SUGGESTIVE_WORDS[i]) == 0)
      not_suggestive =  SUGGESTIVE #indicates negation found
      break
    end
  end
  return not_suggestive
end
#------------------------------------------#------------------------------------------

#Checking if the PHRASE is suggestive
def is_suggestive_phrase(phrase)
  not_suggestive = POSITIVE
  for i in (0..SUGGESTIVE_PHRASES.length - 1)
    if(phrase.casecmp(SUGGESTIVE_PHRASES[i]) == 0)
      not_suggestive =  SUGGESTIVE #indicates negation found
      break
    end
  end
  return not_suggestive
end

end #end of the class