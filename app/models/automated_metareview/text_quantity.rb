require 'automated_metareview/wordnet_based_similarity'
require 'automated_metareview/text_preprocessing'

class TextQuantity
  def number_of_unique_tokens(text_array)
    pre_string = "" #preString helps keep track of the text that has been checked for unique tokens and text that has not
    count = 0 #counts the number of unique tokens
    instance = WordnetBasedSimilarity.new
    text_array.each{
      |text|
      tp = TextPreprocessing.new
      text = tp.contains_punct(text)
      all_tokens = text.split(" ")
      all_tokens.each{ 
        |token|
        if(!instance.is_frequent_word(token.downcase)) #do not count this word if it is a frequent word
          if(!pre_string.downcase.include?(token.downcase)) #if the token was not already seen earlier i.e. not a part of the preString
            count+=1
          end  
        end  
        pre_string = pre_string +" " + token.downcase #adding token to the preString
      }
    }
    return count
  end
end