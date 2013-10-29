require 'automated_metareview/negations'
require 'automated_metareview/constants'

class SentenceState
  @interim_noun_verb
  @state

  @@prev_negative_word

  # Make a new state instance based on the type of the current_state
  def factory(state)
    {POSITIVE => PositiveState, NEGATIVE_DESCRIPTOR => NegativeDescriptorState, NEGATIVE_PHRASE => NegativePhraseState, SUGGESTIVE => SuggestiveState, NEGATIVE_WORD => NegativeWordState}[state].new()
  end

  def identify_sentence_state(str_with_pos_tags)
    # puts("**** Inside identify_sentence_state #{str_with_pos_tags}")
    #ask TaggedSentence class to break the sentence at the co-ordinating conjunction
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

  def sentence_state(sentence_tokens) #str_with_pos_tags)
    #initialize state variables so that the original sentence state is positive
    @state = POSITIVE
    current_state = factory(@state)
    @@prev_negative_word = false

    @interim_noun_verb = false
    sentence_tokens.each_with_next do |curr_token, next_token|
      #get current token type
      current_token_type = get_token_type([curr_token, next_token])

      #Ask State class to get current state based on current state, current_token_type, and if there was a prev_negative_word

      current_state = factory(current_state.next_state(current_token_type))

      #setting the prevNegativeWord
      NEGATIVE_EMPHASIS_WORDS.each do |e|
        if curr_token.casecmp(e)
          @@prev_negative_word = true
        end
      end

    end #end of for loop

    current_state.get_state()
  end
  def get_token_type(current_token)
    #input parsers
    get_word = lambda { |c| c[0]}
    get_phrase = lambda {|c| c[1].nil? ? nil : c[0]+' '+c[1]}

    #types holds relationships between word_or_phrase_array_of_type => [input parser of type, type]
    types = {NEGATED_WORDS => [get_word, NEGATIVE_WORD], NEGATIVE_DESCRIPTORS => [get_word, NEGATIVE_DESCRIPTOR], SUGGESTIVE_WORDS => [get_word, SUGGESTIVE], NEGATIVE_PHRASES => [get_phrase,NEGATIVE_PHRASE], SUGGESTIVE_PHRASES => [get_phrase, SUGGESTIVE]}
    current_token_type = POSITIVE
    types.each do |word_or_phrase_array, type_definition|
      get_word_or_phrase, word_or_phrase_type = type_definition[0], type_definition[1]
      token = get_word_or_phrase.(current_token)
      unless token.nil?
        word_or_phrase_array.each do |word_or_phrase|
            if token.casecmp(word_or_phrase) == 0
              current_token_type = word_or_phrase_type
              break
            end
        end
      end
    end
    current_token_type
  end
  def next_state(current_token_type)
    #@@prev_negative_word = prev_negative_word
    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]
    method.call()
    if @state != POSITIVE
      set_interim_noun_verb(false) #resetting
    end
    @state
  end
  #SentenceState is responsible for keeping track of interim words
  def get_interim_noun_verb
    @interim_noun_verb
  end
  def set_interim_noun_verb(interim_noun_verb)
    @interim_noun_verb = interim_noun_verb
  end

  #if there is an interim word between two states, it will become state1 else it will be state2
  def if_interim_then_state_is(state1, state2)
    if @interim_noun_verb   #there are some words in between
      state = state1
    else
      state = state2
    end
    state
  end
end #end of the class
    #This is a type of state where the sentence clause is positive
class PositiveState < SentenceState


  def negative_word
    #puts "next token is negative"

    @state = NEGATIVE_WORD
  end
  def positive

    @state = POSITIVE
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = NEGATIVE_DESCRIPTOR
    #puts "next token is negative"
  end
  def negative_phrase
    @state = NEGATIVE_PHRASE
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE
    #puts "next token is suggestive"
  end
  def get_state
    #puts "positive"
    POSITIVE
  end
end

#This is a type of state where the sentence clause is negative because of a negative word
class NegativeWordState < SentenceState
  @@prev_negative_word

  def negative_word
    @state = @@prev_negative_word ? POSITIVE : NEGATIVE_WORD

    #state
  end
  def positive
    #puts "next token is positive"
    set_interim_noun_verb(true)
    @state = NEGATIVE_WORD

  end
  def negative_descriptor
    @state = POSITIVE
    #puts "next token is negative"
  end
  def negative_phrase
    @state = POSITIVE
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = if_interim_then_state_is(NEGATIVE_PHRASE, SUGGESTIVE)
    #puts "next token is suggestive"
  end
  def get_state
    #puts "negative_word"
    @state = NEGATED
  end
end
class NegativePhraseState < SentenceState
  def negative_word
    @state = if_interim_then_state_is(NEGATIVE_WORD, POSITIVE)
    #puts "next token is negative"
  end
  def positive
    set_interim_noun_verb(true)
    @state = NEGATIVE_PHRASE
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = NEGATIVE_DESCRIPTOR
    #puts "next token is negative"
  end
  def negative_phrase
    @state = NEGATIVE_PHRASE
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE #e.g.:"I too short and I suggest ..."
                        #puts "next token is suggestive"
  end
  def get_state
    #puts "negative phrase"
    @state = NEGATED
  end
end
class SuggestiveState < SentenceState
  def negative_word
    @state = SUGGESTIVE
    #puts "next token is negative"
  end
  def positive
    @state = SUGGESTIVE
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = NEGATIVE_DESCRIPTOR
    #puts "next token is negative"
  end
  def negative_phrase
    @state = NEGATIVE_PHRASE
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE #e.g.:"I too short and I suggest ..."
                        #puts "next token is suggestive"
  end
  def get_state
    #puts "suggestive"
    SUGGESTIVE
  end
end
class NegativeDescriptorState < SentenceState
  def negative_word
    @state = if_interim_then_state_is(NEGATIVE_WORD, POSITIVE)
    #puts "next token is negative"
  end
  def positive
    set_interim_noun_verb(true)
    @state = NEGATIVE_DESCRIPTOR
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = if_interim_then_state_is(NEGATIVE_DESCRIPTOR, POSITIVE)
    #puts "next token is negative"
  end
  def negative_phrase
    @state = if_interim_then_state_is(NEGATIVE_PHRASE, POSITIVE)
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE #e.g.:"I hardly(-) suggested(S) ..."
                        #puts "next token is suggestive"
  end
  def get_state
    #puts "negative_descriptor"
    NEGATED
  end

end
class Array
  def each_with_next(&block)
    [*self, nil].each_cons(2, &block)
  end
end