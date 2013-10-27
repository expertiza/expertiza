require 'automated_metareview/negations'
require 'automated_metareview/constants'
class State
  def State.factory(state)
    {POSITIVE => PositiveState, NEGATIVE_DESCRIPTOR => NegativeDescriptorState, NEGATIVE_PHRASE => NegativePhraseState, SUGGESTIVE => SuggestiveState, NEGATIVE_WORD => NegativeWordState}[state].new
  end
end
class PositiveState < State
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    state = current_token_type
    return state, interim_noun_verb
  end
  def get_state
    puts "positive"
    return POSITIVE
  end

end
class NegativeWordState < State

  @state
  @prev_negative_word
  @interim_noun_verb

  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    @prev_negative_word = prev_negative_word
    @interim_noun_verb = interim_noun_verb
    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]

    method.call()

    @interim_noun_verb = false #resetting

    return @state, @interim_noun_verb
  end
  def negative_word
      puts "next token is negative"
      if(@prev_negative_word.casecmp("NO") != 0 and @prev_negative_word.casecmp("NEVER") != 0 and @prev_negative_word.casecmp("NONE") != 0)
        @state = POSITIVE #e.g: "not had no work..", "doesn't have no work..", "its not that it doesn't bother me..."
      else
        @state = NEGATIVE_WORD #e.g: "no it doesn't help", "no there is no use for ..."
      end
  end
  def positive
    @state = get_state()
    puts "next token is positive"
  end
  def negative_descriptor
    @state = POSITIVE
    puts "next token is negative"
  end
  def negative_phrase
    @state = POSITIVE
    puts "next token is negative phrase"
  end
  def suggestive
    if(@interim_noun_verb == true) #there are some words in between
      @state = NEGATIVE_WORD
    else
      @state = SUGGESTIVE #e.g.:"I do not(-) suggest(S) ..."
    end
    puts "next token is suggestive"
  end
  def get_state
    puts "negative_word"
    @state = NEGATIVE_WORD
  end
end
class NegativePhraseState < State
  @state
  @prev_negative_word
  @interim_noun_verb

  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    @prev_negative_word = prev_negative_word
    @interim_noun_verb = interim_noun_verb
    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]

    get_state()
    method.call()

    @interim_noun_verb = false #resetting

    return @state, @interim_noun_verb

  end
  def negative_word
    if(@interim_noun_verb == true)#there are some words in between
      @state = NEGATIVE_WORD #e.g."It is too short the text and doesn't"
    else
      @state = POSITIVE #e.g."It is too short not to contain.."
    end
    puts "next token is negative"
  end
  def positive
    puts "next token is positive"
  end
  def negative_descriptor
    @state = NEGATIVE_DESCRIPTOR
    puts "next token is negative"
  end
  def negative_phrase
    @state = NEGATIVE_PHRASE
    puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE #e.g.:"I too short and I suggest ..."
    puts "next token is suggestive"
  end
  def get_state
    puts "negative phrase"
    @state = NEGATIVE_PHRASE
  end
end
class SuggestiveState < State
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    if(current_token_type == NEGATIVE_DESCRIPTOR)
      state = NEGATIVE_DESCRIPTOR
    elsif(current_token_type == NEGATIVE_PHRASE)
      state = NEGATIVE_PHRASE
    end
    #e.g.:"I suggest you don't.." -> suggestive
    interim_noun_verb = false #resetting

    return state , interim_noun_verb
  end
  def get_state
    puts "suggestive"
    return SUGGESTIVE
  end
end
class NegativeDescriptorState < State
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    if(current_token_type == NEGATIVE_WORD)
      if(interim_noun_verb == true)#there are some words in between
        state = NEGATIVE_WORD #e.g: "hard(-) to understand none(-) of the comments"
      else
        state = POSITIVE #e.g."He hardly not...."
      end
      interim_noun_verb = false #resetting
    elsif(current_token_type == NEGATIVE_DESCRIPTOR)
      if(interim_noun_verb == true)#there are some words in between
        state = NEGATIVE_DESCRIPTOR #e.g:"there is barely any code duplication"
      else
        state = POSITIVE #e.g."It is hardly confusing..", but what about "it is a little confusing.."
      end
      interim_noun_verb = false #resetting
    elsif(current_token_type == NEGATIVE_PHRASE)
      if(interim_noun_verb == true)#there are some words in between
        state = NEGATIVE_PHRASE #e.g:"there is barely any code duplication"
      else
        state = POSITIVE #e.g.:"it is hard and appears to be taken from"
      end
                                #interim_noun_verb = false #resetting
    elsif(current_token_type == SUGGESTIVE)
      state = SUGGESTIVE #e.g.:"I hardly(-) suggested(S) ..."

    end
    interim_noun_verb = false #resetting

    return state, interim_noun_verb
  end
  def get_state
    puts "negative_descriptor"
    return NEGATIVE_DESCRIPTOR
  end

end