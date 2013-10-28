require 'automated_metareview/negations'
require 'automated_metareview/constants'

class SentenceState
  #attr_accessor :broken_sentences
  def identify_sentence_state(str_with_pos_tags)
    # puts("**** Inside identify_sentence_state #{str_with_pos_tags}")
    #break the sentence at the co-ordinating conjunction
    sentence = TaggedSentence.new(str_with_pos_tags)
    sentences_sections = sentence.break_at_coord_conjunctions()

    states_array = Array.new
    i = 0
    sentences_sections.each do |section_tokens|
      states_array[i] = sentence_state(section_tokens)
      i+=1
    end
    
    states_array
  end #end of the methods

  def sentence_state(tokens) #str_with_pos_tags)
    #initialize state variables so that the original sentence state is positive
    state = POSITIVE
    current_state = State.factory(state)
    prev_negative_word = false

    tokens.each_with_next do |curr_token, next_token|
      #get current token type
      current_token_type = get_token_type([curr_token, next_token])

      #Ask State class to get current state based on current state, current_token_type, and if there was a prev_negative_word
      current_state = State.factory(current_state.next_state(current_token_type, prev_negative_word))

      #setting the prevNegativeWord
      NEGATIVE_EMPHASIS_WORDS.each do |e|
        if curr_token.casecmp(e)
          prev_negative_word = true
        end
      end

    end #end of for loop

    current_state.get_state()
  end
  def get_token_type(current_token)
    #type_methods = [self.method(:is_negative_word), self.method(:is_negative_descriptor), self.method(:is_suggestive), self.method(:is_negative_phrase), self.method(:is_suggestive_phrase)]
    is_word = lambda { |c| c[0]}
    is_phrase = lambda do |c|
      if c[1].nil?
        nil
      else
        c[0]+' '+c[1]
      end
      end
    types = {NEGATED_WORDS => [is_word, NEGATIVE_WORD], NEGATIVE_DESCRIPTORS => [is_word, NEGATIVE_DESCRIPTOR], SUGGESTIVE_WORDS => [is_word, SUGGESTIVE], NEGATIVE_PHRASES => [is_phrase,NEGATIVE_PHRASE], SUGGESTIVE_PHRASES => [is_phrase, SUGGESTIVE]}
    current_token_type = POSITIVE
    types.each do |type, w|
      get_word_or_phrase = w[0]
      word_or_phrase_type = w[1]
      token = get_word_or_phrase.(current_token)
      unless token.nil?
        type.each do |t|
            if token.casecmp(t) == 0
              current_token_type = word_or_phrase_type
              break
            end
        end
      end
    end
    current_token_type
  end
end #end of the class

class Array
  def each_with_next(&block)
    [*self, nil].each_cons(2, &block)
  end
end