require 'automated_metareview/negations'
require 'automated_metareview/constants'

class State
  @interim_noun_verb
  @state
  @prev_negative_word
  # Make a new state instance based on the type of the current_state
  def State.factory(state)
    {POSITIVE => PositiveState, NEGATIVE_DESCRIPTOR => NegativeDescriptorState, NEGATIVE_PHRASE => NegativePhraseState, SUGGESTIVE => SuggestiveState, NEGATIVE_WORD => NegativeWordState}[state].new()
  end


  def initialize
    @interim_noun_verb = false
  end


  def next_state(current_token_type, prev_negative_word)
    @prev_negative_word = prev_negative_word
    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]
    method.call()

    if @state != POSITIVE
      set_interim_noun_verb(false) #resetting
    end
    @state
  end

  #State is responsible for keeping track of interim words
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
end

#This is a type of state where the sentence clause is positive
class PositiveState < State

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
class NegativeWordState < State


  def negative_word
      #puts "next token is negative"
      if @prev_negative_word
        @state = POSITIVE #e.g: "not had no work..", "doesn't have no work..", "its not that it doesn't bother me..."
      else
        @state = NEGATIVE_WORD #e.g: "no it doesn't help", "no there is no use for ..."
      end
  end
  def positive
    set_interim_noun_verb(true)
    @state = NEGATIVE_WORD
    #puts "next token is positive"
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
class NegativePhraseState < State

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
class SuggestiveState < State

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
class NegativeDescriptorState < State

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