require 'automated_metareview/constants'
require 'automated_metareview/edge'
require 'automated_metareview/vertex'

class TextPreprocessing

=begin
 Fetching review data from the tables based on the response_map id 
=end  
  def fetch_review_data(auto_metareview, map_id)
    reviews = Array.new
    responses = Response.find(:first, :conditions => ["map_id = ?", map_id], :order => "version_num DESC")
    auto_metareview.responses = responses
    auto_metareview.response_id = responses.id
    # puts "auto_metareview.response_id #{auto_metareview.response_id}"
    # puts "responses version number #{responses.version_num}"
    responses.scores.each{
      | review_score |
      if(review_score.comments != nil and !review_score.comments.rstrip.empty?)
        # puts review_score.comments
        reviews << review_score.comments        
      end
    }
    return reviews
  end
#------------------------------------------#------------------------------------------#------------------------------------------
=begin
 Fetching submission data from the url submitted by the reviewee 
=end
  def fetch_submission_data(map_id)
    subm_array = Array.new
    reviewee_id = ResponseMap.find(:first, :conditions => ["id = ?", map_id]).reviewee_id
    url = Participant.find(:first, :conditions => ["id = ?", reviewee_id]).submitted_hyperlinks
    #fetching the url submitted by the reviewee
    url = url[url.rindex("http")..url.length-2] #use "rindex" to fetch last occurrence of the substring - useful if there are multiple urls
    puts "***url #{url} #{url.class}"
    page = Nokogiri::HTML(open(url))
    #fetching the paragraph texts from the specified url
    if(page.css('p').count != 0)
      page.css('p').each do |subm|
        # puts "subm.text.. #{subm.text}"
        subm_array << subm.text 
      end 
    end
    #for google docs where the text is placed inside <script></script> tags
    if(page.css('script').count != 0)
      page.css('script').each do |subm|
        if(!subm.children[0].to_s.index("\"s\":\"").nil? and !subm.children[0].to_s.index("\\n\"},").nil?) #the string indicates the beginning of the text in the script
          subm_array << subm.children[0].to_s[subm.children[0].to_s.index("\"s\":\"")+5, subm.children[0].to_s.index("\\n\"},")]
        end
      end
    end
    return subm_array  
  end
#------------------------------------------#------------------------------------------#------------------------------------------  
=begin
  pre-processes the review text and sends it in for graph formation and further analysis
=end
def segment_text(flag, text_array)
  if(flag == 0)
    reviews = Array.new(1){Array.new}
  else
    reviews = Array.new(50){Array.new} #50 is the number of different reviews/submissions
  end
  
  i = 0
  j = 0
  
  for k in (0..text_array.length-1)
    text = text_array[k]
    if(flag == 1) #reset i (the sentence counter) to 0 for test reviews
      reviews[j] = Array.new #initializing the array for sentences in a test review
      i = 0
    end
    
    #******* Pre-processing the review/submission text **********
    #replacing commas in large numbers, makes parsing sentences with commas confusing!
    #replacing quotation marks
    text.gsub!("\"", "")
    text.gsub!("(", "")
    text.gsub!(")", "")
    if(text.include?("http://"))
      text = remove_urls(text)
    end
    #break the text into multiple sentences
    beginn = 0
    if(text.include?(".") or text.include?("?") or text.include?("!") or text.include?(",") or text.include?(";") ) #new clause or sentence
      while(text.include?(".") or text.include?("?") or text.include?("!") or text.include?(",") or text.include?(";")) do #the text contains more than 1 sentence
        endd = 0
        #these 'if' conditions have to be independent, cause the value of 'endd' could change for the different types of punctuations
        if(text.include?("."))
          endd = text.index(".")
        end
        if((text.include?("?") and endd != 0 and endd > text.index("?")) or (text.include?("?") and endd == 0))#if a ? occurs before a .
          endd = text.index("?")
        end
        if((text.include?("!") and endd!= 0 and endd > text.index("!")) or (text.include?("!") and endd ==0))#if an ! occurs before a . or a ?
          endd = text.index("!")
        end
        if((text.include?(",") and endd != 0 and endd > text.index(",")) or (text.include?(",") and endd == 0)) #if a , occurs before any of . or ? or ! 
          endd = text.index(",")
        end
        if((text.include?(";") and endd != 0 and endd > text.index(";")) or (text.include?(";") and endd == 0)) #if a ; occurs before any of . or ?, ! or , 
          endd = text.index(";")
        end
              
        #check if the string between two commas or punctuations is there to buy time e.g. ", say," ",however," ", for instance, "... 
        if(flag == 0) #training
          reviews[0][i] = text[beginn..endd].strip
        else #testing
          reviews[j][i] = text[beginn..endd].strip
        end        
        i+=1 #incrementing the sentence counter
        text = text[(endd+1)..text.length] #from end+1 to the end of the string variable
      end #end of the while loop   
    else #if there is only 1 sentence in the text
      if(flag == 0)#training            
        reviews[0][i] = text.strip
        i+=1 #incrementing the sentence counter
      else #testing
        reviews[j][i] = text.strip
      end
    end
  
    if(flag == 1)#incrementing reviews counter only for test reviews
      j+=1
    end 
  end #end of the for loop with 'k' reading text rows
  
  #setting the number of reviews before returning
  if(flag == 0)#training
    num_reviews = 1 #for training the number of reviews is 1
  else #testing
    num_reviews = j
  end

  if(flag == 0)
    return reviews[0]
  end
end
#------------------------------------------#------------------------------------------#------------------------------------------
=begin
   * Reads the patterns from the csv file containing them. 
   * maxValue is the maximum value of the patterns found
=end

def read_patterns(filename, pos)
  num = 1000 #some large number
  patterns = Array.new
  state = POSITIVE
  i = 0 #keeps track of the number of edges
  
  #setting the state for problem detection and suggestive patterns
  if(filename.include?("prob"))
      state = NEGATED
  elsif(filename.include?("suggest"))
      state = SUGGESTIVE
  end
    
  FasterCSV.foreach(filename) do |text|
    in_vertex = text[0][0..text[0].index("=")-1].strip
    out_vertex = text[0][text[0].index("=")+2..text[0].length].strip

    first_string_in_vertex = pos.get_readable(in_vertex.split(" ")[0]) #getting the first token in vertex to determine POS
    first_string_out_vertex = pos.get_readable(out_vertex.split(" ")[0]) #getting the first token in vertex to determine POS
      
     patterns[i] = Edge.new("noun", NOUN)
     #setting the invertex
     if(first_string_in_vertex.include?("/NN") or first_string_in_vertex.include?("/PRP") or first_string_in_vertex.include?("/IN") or first_string_in_vertex.include?("/EX") or first_string_in_vertex.include?("/WP"))
          patterns[i].in_vertex = Vertex.new(in_vertex, NOUN, i, state, nil, nil, first_string_in_vertex[first_string_in_vertex.index("/")+1..first_string_in_vertex.length])
     elsif(first_string_in_vertex.include?("/VB") or first_string_in_vertex.include?("MD"))
      patterns[i].in_vertex = Vertex.new(in_vertex, VERB, i, state, nil, nil, first_string_in_vertex[first_string_in_vertex.index("/")+1..first_string_in_vertex.length])
     elsif(first_string_in_vertex.include?("JJ"))
      patterns[i].in_vertex = Vertex.new(in_vertex, ADJ, i, state, nil, nil, first_string_in_vertex[first_string_in_vertex.index("/")+1..first_string_in_vertex.length])
     elsif(first_string_in_vertex.include?("/RB"))
      patterns[i].in_vertex = Vertex.new(in_vertex, ADV, i, state, nil, nil, first_string_in_vertex[first_string_in_vertex.index("/")+1..first_string_in_vertex.length]) 
     else #default to noun
      patterns[i].in_vertex = Vertex.new(in_vertex, NOUN, i, state, nil, nil, first_string_in_vertex[first_string_in_vertex.index("/")+1..first_string_in_vertex.length])
     end      
     
     #setting outvertex
     if(first_string_out_vertex.include?("/NN") or first_string_out_vertex.include?("/PRP") or first_string_out_vertex.include?("/IN") or first_string_out_vertex.include?("/EX") or first_string_out_vertex.include?("/WP"))
      patterns[i].out_vertex = Vertex.new(out_vertex, NOUN, i, state, nil, nil, first_string_out_vertex[first_string_out_vertex.index("/")+1..first_string_out_vertex.length])
     elsif(first_string_out_vertex.include?("/VB") or first_string_out_vertex.include?("MD"))
      patterns[i].out_vertex = Vertex.new(out_vertex, VERB, i, state, nil, nil, first_string_out_vertex[first_string_out_vertex.index("/")+1..first_string_out_vertex.length])
     elsif(first_string_out_vertex.include?("JJ"))
      patterns[i].out_vertex = Vertex.new(out_vertex, ADJ, i, state, nil, nil, first_string_out_vertex[first_string_out_vertex.index("/")+1..first_string_out_vertex.length-1]);
     elsif(first_string_out_vertex.include?("/RB"))
      patterns[i].out_vertex = Vertex.new(out_vertex, ADV, i, state, nil, nil, first_string_out_vertex[first_string_out_vertex.index("/")+1..first_string_out_vertex.length])  
    else #default is noun
      patterns[i].out_vertex = Vertex.new(out_vertex, NOUN, i, state, nil, nil, first_string_out_vertex[first_string_out_vertex.index("/")+1..first_string_out_vertex.length])
    end
    i+=1 #incrementing for each pattern 
  end #end of the FasterCSV.foreach loop
  num_patterns = i
  return patterns
end

#------------------------------------------#------------------------------------------#------------------------------------------

=begin
 Removes any urls in the text and returns the remaining text as it is 
=end
def remove_urls(text)
  final_text = String.new
  if(text.include?("http://"))
    tokens = text.split(" ")
    tokens.each{
      |token|
      if(!token.include?("http://"))
        final_text = final_text + " " + token
      end  
    }
  else
    return text
  end
  return final_text  
end
#------------------------------------------#------------------------------------------#------------------------------------------

=begin
Check for plagiarism after removing text within quotes for reviews
=end
def remove_text_within_quotes(review_text)
  puts "Inside removeTextWithinQuotes:: "
  reviews = Array.new
  review_text.each{ |row|
    puts "row #{row}"
    text = row 
    #text = text[1..text.length-2] #since the first and last characters are quotes
    #puts "text #{text}"
    #the read text is tagged with two sets of quotes!
    if(text.include?("\""))
      while(text.include?("\"")) do
        replace_text = text.scan(/"([^"]*)"/)
        # puts "replace_text #{replace_text[0]}.. #{replace_text[0].to_s.class} .. #{replace_text.length}"
        # puts text.index(replace_text[0].to_s)
        # puts "replace_text length .. #{replace_text[0].to_s.length}"
        #fetching the start index of the quoted text, in order to replace the complete segment
        start_index = text.index(replace_text[0].to_s) - 1 #-1 in order to start from the quote
        # puts "text[start_index..start_index + replace_text[0].to_s.length+1] .. #{text[start_index.. start_index + replace_text[0].to_s.length+1]}"
        #replacing the text segment within the quotes (including the quotes) with an empty string
        text.gsub!(text[start_index..start_index + replace_text[0].to_s.length+1], "")
        puts "text .. #{text}"
      end #end of the while loop
    end
    reviews << text #set the text after all quoted segments have been removed.
  } #end of the loop for "text" array
  puts "returning reviews length .. #{reviews.length}"
  return reviews #return only the first array element - a string!
end
#------------------------------------------#------------------------------------------#------------------------------------------   
=begin
 Looks for spelling mistakes in the text and fixes them using the raspell library available for ruby 
=end
def check_correct_spellings(review_text_array, speller)
  review_text_array_temp = Array.new
  #iterating through each response
  review_text_array.each{
    |review_text|
    review_tokens = review_text.split(" ")
    review_text_temp = ""
    #iterating through tokens from each response
    review_tokens.each{
      |review_tok|
      #checkiing the stem word's spelling for correctness
      if(!speller.check(review_tok))
        if(!speller.suggest(review_tok).first.nil?)
          review_tok = speller.suggest(review_tok).first
        end
     end
     review_text_temp = review_text_temp +" " + review_tok.downcase
    }
    review_text_array_temp << review_text_temp
  }
  return review_text_array_temp
end

#------------------------------------------#------------------------------------------#------------------------------------------
=begin
 Checking if "str" is a punctuation mark like ".", ",", "?" etc. 
=end
public #The method was throwing a "NoMethodError: private method" error when called from a different class. Hence the "public" keyword.
def contains_punct(str)
  if(str.include?".")
    str.gsub!(".","")
  elsif(str.include?",")
    str.gsub!(",","")
  elsif(str.include?"?")
    str.gsub!("?","")
  elsif(str.include?"!")
    str.gsub!("!","") 
  elsif(str.include?";")
    str.gsub(";","")
  elsif(str.include?":")
    str.gsub!(":","")
  elsif(str.include?"(")
    str.gsub!("(","")
  elsif(str.include?")")
    str.gsub!(")","")
  elsif(str.include?"[")
    str.gsub!("[","")
  elsif(str.include?"]")
    str.gsub!("]","")  
  end 
  return str
end 

def contains_punct_bool(str)
  if(str.include?("\\n") or str.include?("}") or str.include?("{"))
    return true
  else
    return false
  end 
end

#------------------------------------------#------------------------------------------#------------------------------------------
=begin
 Checking if "str" is a punctuation mark like ".", ",", "?" etc. 
=end
def is_punct(str)
  if(str == "." or str == "," or str == "?" or str == "!" or str == ";" or str == ":")
    return true
  else
    return false
  end 
end 

end #end of class