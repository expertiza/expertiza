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

    num_of_tokens = 0
    interim_noun_verb  = false #0 indicates no interim nouns or verbs

    num_of_tokens, tagged_tokens, tokens = parse_sentence_tokens(num_of_tokens, st)

    #iterating through the tokens to determine state
    prev_negative_word =""
    state_var = State.factory(state)
    #next_state = state
    for j  in (0..num_of_tokens-1)
      #checking type of the word
      #checking for negated words or phrases
      type_methods = [self.method(:is_negative_word), self.method(:is_negative_descriptor), self.method(:is_suggestive), self.method(:is_negative_phrase), self.method(:is_suggestive_phrase)]
      current_token_type = POSITIVE
      type_methods.each do |what_type_is|
        if current_token_type == POSITIVE
          current_token_type = what_type_is.call(tokens[j..(num_of_tokens-1)])
        end
      end
      #puts tokens[j]
      #puts returned_type

      #----------------------------------------------------------------------
      #comparing 'returnedType' with the existing STATE of the sentence clause
      #after returnedType is identified, check its state and compare it to the existing state
      #if present state is negative and an interim non-negative or non-suggestive word was found, set the flag to true
      if((state == NEGATIVE_WORD or state == NEGATIVE_DESCRIPTOR or state == NEGATIVE_PHRASE) and current_token_type == POSITIVE)
        if(interim_noun_verb == false and (tagged_tokens[j].include?("NN") or tagged_tokens[j].include?("PR") or tagged_tokens[j].include?("VB") or tagged_tokens[j].include?("MD")))
          interim_noun_verb = true
        end
      end
      double_negative = false
      #print "I am in the state "
      #puts state
      state, interim_noun_verb = state_var.next_state(current_token_type, prev_negative_word, interim_noun_verb)
      state_var = State.factory(state)

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

  def parse_sentence_tokens(i, st)
    tokens = Array.new
    tagged_tokens = Array.new
    #fetching all the tokens
    for k in (0..st.length-1)
      ps = st[k]
      #setting the tagged string
      tagged_tokens[i] = ps
      if (ps.include?("/"))
        ps = ps[0..ps.index("/")-1]
      end
      #removing punctuations
      if (ps.include?("."))
        tokens[i] = ps[0..ps.index(".")-1]
      elsif (ps.include?(","))
        tokens[i] = ps.gsub(",", "")
      elsif (ps.include?("!"))
        tokens[i] = ps.gsub("!", "")
      elsif (ps.include?(";"))
        tokens[i] = ps.gsub(";", "")
      else
        tokens[i] = ps
        i+=1
      end
    end
    #end of the for loop
    return i, tagged_tokens, tokens
  end

#------------------------------------------#------------------------------------------

#Checking if the token is a negative token
  def is_negative_word(word_array)
    word = word_array.first
    not_negated = POSITIVE
    for i in (0..NEGATED_WORDS.length - 1)
      if(word.casecmp(NEGATED_WORDS[i]) == 0)
        not_negated =  NEGATIVE_WORD #indicates negation found
        break
      end
    end
    return not_negated
  end
#------------------------------------------#------------------------------------------

#Checking if the token is a negative token
  def is_negative_descriptor(word_array)
    word = word_array.first
    not_negated = POSITIVE
    for i in (0..NEGATIVE_DESCRIPTORS.length - 1)
      if(word.casecmp(NEGATIVE_DESCRIPTORS[i]) == 0)
        not_negated =  NEGATIVE_DESCRIPTOR #indicates negation found
        break
      end
    end
    return not_negated
  end

#------------------------------------------#------------------------------------------

#Checking if the phrase is negative
  def is_negative_phrase(word_array)
    not_negated = POSITIVE
    if word_array.size > 1
      phrase = word_array[0]+" "+word_array[1]

      for i in (0..NEGATIVE_PHRASES.length - 1)
        if(phrase.casecmp(NEGATIVE_PHRASES[i]) == 0)
          not_negated =  NEGATIVE_PHRASE #indicates negation found
          break
        end
      end
    end

    return not_negated
  end

#------------------------------------------#------------------------------------------
#Checking if the token is a suggestive token
  def is_suggestive(word_array)
    word = word_array.first
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
  def is_suggestive_phrase(word_array)
    not_suggestive = POSITIVE
    if word_array.size > 1
      phrase = word_array[0]+" "+word_array[1]

      for i in (0..SUGGESTIVE_PHRASES.length - 1)
        if(phrase.casecmp(SUGGESTIVE_PHRASES[i]) == 0)
          not_suggestive =  SUGGESTIVE #indicates negation found
          break
        end
      end
    end
    return not_suggestive
  end

end #end of the class
