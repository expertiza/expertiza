require 'automated_metareview/text_preprocessing'
require 'automated_metareview/constants'
require 'automated_metareview/graph_generator'
require 'ruby-web-search'

class PlagiarismChecker
=begin
 reviewText and submText are array containing review and submission texts 
=end
def check_for_plagiarism(review_text, subm_text)
  result = false
  for l in 0..review_text.length - 1 #iterating through the review's sentences
    review = review_text[l].to_s
    # puts "review.class #{review.to_s.class}.. review - #{review}"
    for m in 0..subm_text.length - 1 #iterating though the submission's sentences
      submission = subm_text[m].to_s  
      # puts "submission.class #{submission.to_s.class}..submission - #{submission}"
      rev_len = 0
      
      rev = review.split(" ") #review's tokens, taking 'n' at a time
      array = review.split(" ")
      
      while(rev_len < array.length) do
        if(array[rev_len] == " ") #skipping empty
          rev_len+=1
          next
        end
        
        #generating the sentence segment you'd like to compare
        rev_phrase = array[rev_len]
        add = 0 #add on to this when empty strings found  
        for j in rev_len+1..(NGRAM+rev_len+add-1) #concatenating 'n' tokens
          if(j < array.length)
            if(array[j] == "") #skipping empty
              add+=1
              next
            end
            rev_phrase = rev_phrase +" "+  array[j]
          end
        end
        
        if(j == array.length)
          #if j has reached the end of the array, then reset rev_len to the end of array to, or shorter strings will be compared
          rev_len = array.length
        end
        
        #replacing punctuation
        tp = TextPreprocessing.new
        submission = tp.contains_punct(submission)
        rev_phrase = tp.contains_punct(rev_phrase)
        #puts "Review phrase: #{rev_phrase} .. #{rev_phrase.split(" ").length}"
        
        #checking if submission contains the review and that only NGRAM number of review tokens are compared
        if(rev_phrase.split(" ").length == NGRAM and submission.downcase.include?(rev_phrase.downcase))
          result = true
          break
        end
        #System.out.println("^^^ Plagiarism result:: "+result);
        rev_len+=1
      end #end of the while loop
      if(result == true)
        break
      end  
    end #end of for loop for submission
    if(result == true)
      break
    end
  end #end of for loop for reviews    
  return result
end
#-------------------------

=begin
 Checking if the response has been copied from the review questions or from other responses submitted. 
=end  
  def compare_reviews_with_questions_responses(auto_metareview, map_id)
    review_text_arr = auto_metareview.review_array
    response = Response.find(:first, :conditions => ["map_id = ?", map_id])
    scores = Score.find(:all, :conditions => ["response_id = ?", response.id])
    questions = Array.new
    #fetching the questions for the responses
    for i in 0..scores.length - 1
      questions << Question.find_by_sql(["Select * from questions where id = ?", scores[i].question_id])[0].txt
    end
    
    count_copies = 0 #count of the number of responses that are copies either of questions of other responses
    rev_array = Array.new #holds the non-plagiairised responses
    #comparing questions with text
    for i in 0..scores.length - 1
      if(!questions[i].nil? and !review_text_arr[i].nil? and questions[i].downcase == review_text_arr[i].downcase)
        count_copies+=1
        next #skip comparing with other responses
      end
      
      #comparing response with other responses
      flag = 0
      for j in 0..review_text_arr.length - 1
        if(i != j and !review_text_arr[i].nil? and !review_text_arr[j].nil? and review_text_arr[i].downcase == review_text_arr[j].downcase)
          count_copies+=1
          flag = 1
          break
        end
      end

      if(flag == 0) #ensuring no match with any of the review array's responses
        rev_array << review_text_arr[i]
      end
    end
    
    #setting @review_array as rev_array
    if(count_copies > 0) #resetting review_array only when plagiarism was found
       auto_metareview.review_array = rev_array
    end
    
    if(count_copies > 0 and count_copies == scores.length)
      return ALL_RESPONSES_PLAGIARISED #plagiarism, with all other metrics 0
    elsif(count_copies > 0)
      return SOME_RESPONSES_PLAGIARISED #plagiarism, while evaluating other metrics
    end
  end

=begin
 Checking if the response was copied from google 
=end
  def google_search_response(auto_metareview)
    review_text_arr = auto_metareview.review_array
    # require 'ruby-web-search'
    count = 0
    temp_array = Array.new
    review_text_arr.each{
      |rev_text|
      if(!rev_text.nil?)
        #placing the search text within quotes to search exact match for the complete text
        response = RubyWebSearch::Google.search(:query => "\""+ rev_text +"\"") 
        #if the results are greater than 0, then the text has been copied
        if(response.results.length > 0)
          count+=1
        else
          temp_array << rev_text #copying the non-plagiarised text for evaluation
        end
      end
    }
    #setting temp_array as the @review_array
    auto_metareview.review_array = temp_array
    
    if(count > 0)
      return true
    else
      return false
    end
  end
  
end

    
