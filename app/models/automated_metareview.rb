require 'automated_metareview/text_preprocessing'
require 'automated_metareview/predict_class'
require 'automated_metareview/degree_of_relevance'
require 'automated_metareview/plagiarism_check'
require 'automated_metareview/tone'
require 'automated_metareview/text_quantity'
require 'automated_metareview/constants'

#gem install edavis10-ruby-web-search
#gem install google-api-client

class AutomatedMetareview < ActiveRecord::Base
  #belongs_to :response, :class_name => 'Response', :foreign_key => 'response_id'
  #has_many :scores, :class_name => 'Score', :foreign_key => 'response_id', :dependent => :destroy
  attr_accessor :responses, :review_array
  #the code that drives the metareviewing
  def calculate_metareview_metrics(response, map_id)
    # puts "inside perform_metareviews!!"    
    
    preprocess = TextPreprocessing.new
    # puts "map_id #{map_id}"
    #fetch the review data as an array 
    @review_array = preprocess.fetch_review_data(self, map_id)
    # puts "self.responses #{self.responses}"
    
    speller = Aspell.new("en_US")
    speller.suggestion_mode = Aspell::NORMAL
    #@review_array = preprocess.check_correct_spellings(@review_array, speller)
    # puts "printing review_array"
    #@review_array.each{
      #|rev|
      #puts rev
    #}
    
    #checking for plagiarism by comparing with question and responses
    plag_instance = PlagiarismChecker.new
    result_comparison = plag_instance.compare_reviews_with_questions_responses(self, map_id)
    # puts "review_array.length #{@review_array.length}"
    
    if(result_comparison == ALL_RESPONSES_PLAGIARISED)
      self.content_summative = 0
      self.content_problem = 0 
      self.content_advisory =  0
      self.relevance = 0
      self.quantity = 0
      self.tone_positive = 0
      self.tone_negative = 0
      self.tone_neutral =  0
      self.plagiarism = true
      #puts "All responses are copied!!"
      return
    elsif(result_comparison == SOME_RESPONSES_PLAGIARISED)
      self.plagiarism = true
    end
    
    #checking plagiarism (by comparing responses with search results from google), we look for quoted text, exact copies i.e.
    google_plagiarised = plag_instance.google_search_response(self)
    if(google_plagiarised == true)
      self.plagiarism = true
    else
      self.plagiarism = false
    end
    
    #puts "length of review array after google check - #{@review_array.length}"
    
    if(@review_array.length > 0)
      #formatting the review responses, segmenting them at punctuations
      review_text = preprocess.segment_text(0, @review_array)
      #removing quoted text from reviews
      review_text = preprocess.remove_text_within_quotes(review_text) #review_text is an array
            
      #fetching submission data as an array and segmenting them at punctuations    
      subm_text = preprocess.segment_text(0, preprocess.fetch_submission_data(map_id))
      # puts "subm_text #{subm_text}"
      # #initializing the pos tagger and nlp tagger/semantic parser  
      pos_tagger = EngTagger.new
      core_NLP_tagger =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
      
      #---------    
      #relevance
      beginning_time = Time.now
      relev = DegreeOfRelevance.new
      self.relevance = relev.get_relevance(review_text, subm_text, 1, pos_tagger, core_NLP_tagger, speller) #1 indicates the number of reviews
      #assigninging the graph generated for the review to the class variable, in order to reuse it for content classification
      review_graph = relev.review
      #calculating end time
      end_time = Time.now
      relevance_time = end_time - beginning_time
      #puts "************* relevance_time - #{relevance_time}"      
      
      #---------    
      # checking for plagiarism
      if(self.plagiarism != true) #if plagiarism hasn't already been set
        beginning_time = Time.now
        result = plag_instance.check_for_plagiarism(review_text, subm_text)
        if(result == true)
          self.plagiarism = "TRUE"
        else
          self.plagiarism = "FALSE"
        end
        end_time = Time.now
        plagiarism_time = end_time - beginning_time
        #puts "************* plagiarism_time - #{plagiarism_time}"
      end
      #---------      
      #content
      beginning_time = Time.now
      content_instance = PredictClass.new
      pattern_files_array = ["app/models/automated_metareview/patterns-assess.csv",
        "app/models/automated_metareview/patterns-prob-detect.csv",
        "app/models/automated_metareview/patterns-suggest.csv"]
      #predcting class - last parameter is the number of classes
      content_probs = content_instance.predict_classes(pos_tagger, core_NLP_tagger, review_text, review_graph, pattern_files_array, pattern_files_array.length)
      #self.content = "SUMMATIVE - #{(content_probs[0] * 10000).round.to_f/10000}, PROBLEM - #{(content_probs[1] * 10000).round.to_f/10000}, SUGGESTION - #{(content_probs[2] * 10000).round.to_f/10000}"
      end_time = Time.now
      content_time = end_time - beginning_time
      self.content_summative = content_probs[0]# * 10000).round.to_f/10000
      self.content_problem = content_probs[1] #* 10000).round.to_f/10000
      self.content_advisory = content_probs[2] #* 10000).round.to_f/10000
      #puts "************* content_time - #{content_time}"
      #---------    
      # tone
      beginning_time = Time.now
      ton = Tone.new
      tone_array = Array.new
      tone_array = ton.identify_tone(pos_tagger, core_NLP_tagger, review_text, review_graph)
      self.tone_positive = tone_array[0]#* 10000).round.to_f/10000
      self.tone_negative = tone_array[1]#* 10000).round.to_f/10000
      self.tone_neutral = tone_array[2]#* 10000).round.to_f/10000
      #self.tone = "POSITIVE - #{(tone_array[0]* 10000).round.to_f/10000}, NEGATIVE - #{(tone_array[1]* 10000).round.to_f/10000}, NEUTRAL - #{(tone_array[2]* 10000).round.to_f/10000}"
      end_time = Time.now
      tone_time = end_time - beginning_time
      #puts "************* tone_time - #{tone_time}"
      # #---------
      # quantity
      beginning_time = Time.now
      quant = TextQuantity.new
      self.quantity = quant.number_of_unique_tokens(review_text)
      end_time = Time.now
      quantity_time = end_time - beginning_time
      #puts "************* quantity_time - #{quantity_time}"
      # #---------     
      # # fetch version_num for this new response_id if previous versions of this response already exists in the table
      @metas = AutomatedMetareview.find(:first, :conditions => ["response_id = ?", self.response_id], :order => "version_num DESC")
      if !@metas.nil? and !@metas.version_num.nil?
        version = @metas.version_num + 1
      else
        version = 1 #no metareviews exist with that response_id, so set the version to 1
      end
      self.version_num = version
    end
  end

  
=begin
The following method 'send_metareview_metrics_email' sends an email to the reviewer 
listing his/her metareview metrics values.  
=end  
  def send_metareview_metrics_email(response, map_id)
     response_id = self.response_id
     reviewer_id = ResponseMap.find_by_id(map_id).reviewer
     
     reviewer_email = User.find_by_id(Participants.fin_by_id(reviewer_id).user_id).email
     reviewed_url = @url
      
     body_text = "The metareview metrics for review #{@url} are as follows: " 
     body_text = body_text + " Relevance: " + self.relevance
     body_text = body_text + " Quantity: " + self.plagiarism
     body_text = body_text + " Plagiarised: " + self.quantity
     body_text = body_text + " Content Type: Summative content " + self.content_summative.to_s + 
                " Problem content "+self.content_problem.to_s + " Advisory content " + self.content_advisory
     body_text = body_text + " Tone Type: Postive tone " + self.tone_positive.to_s + 
                " Negative tone "+self.tone_negative.to_s + " Neutral tone " + self.tone_neutral

    Mailer.deliver_message(
            {:recipients => reviewer_email,
             :subject => "Your metareview metrics for review of Assignment",
             :from => email_form[:from],
             :body => {
                     :body_text => body_text
             }
            }
    )

    flash[:notice] = "Your metareview metrics have been emailed."
  end
end