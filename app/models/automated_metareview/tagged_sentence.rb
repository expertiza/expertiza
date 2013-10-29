class TaggedSentence
  @str_with_pos_tags
  def initialize(str_with_pos_tags)
     @str_with_pos_tags = str_with_pos_tags
  end
  def parse_sentence_tokens(str_with_pos_tags)
    sentence_pieces = str_with_pos_tags.split(' ')
    num_tokens = 0
    tokens = Array.new

    tag = '/'
    punctuation = %w(. , ! ;)
    sentence_pieces.each do |sp|
      #remove tag from sentence word
      if sp.include?(tag)
        sp = sp[0..sp.index(tag)-1]
      end

      valid_token = true
      punctuation.each do |p|
        if sp.include?(p)
          valid_token = false
          break
        end
      end
      if valid_token
        tokens[num_tokens] = sp
        num_tokens+=1
      end
    end
    #end of the for loop
    tokens
  end
  def break_at_coord_conjunctions
    st = @str_with_pos_tags.split(' ')
    counter = 0

    sentences_sections = Array.new
    #if the sentence contains a co-ordinating conjunction
    if @str_with_pos_tags.include?('CC')
      counter = 0
      temp = ''
      st.each do |ps|
        if !ps.nil? and ps.include?('CC')
          sentences_sections[counter] = parse_sentence_tokens(temp) #for "run/NN on/IN..."
          counter+=1
          temp = ps[0..ps.index('/')]
          #the CC or IN goes as part of the following sentence
        elsif !ps.nil? and !ps.include?('CC')
          temp += ' '+ ps[0..ps.index('/')]
        end
      end
      unless temp.empty? #setting the last sentence segment
        sentences_sections[counter] = parse_sentence_tokens(temp)
        counter+=1
      end
    else
      sentences_sections[counter] = parse_sentence_tokens(@str_with_pos_tags)
      counter+=1
    end

    sentences_sections
  end #end of the method
end