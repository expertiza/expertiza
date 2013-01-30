class Response < ActiveRecord::Base
  belongs_to :map, :class_name => 'ResponseMap', :foreign_key => 'map_id'
  has_many :scores, :class_name => 'Score', :foreign_key => 'response_id', :dependent => :destroy
  
  def display_as_html(prefix = nil, count = nil, file_url = nil)
    identifier = ""
    # The following three lines print out the type of rubric before displaying
    # feedback.  Currently this is only done if the rubric is Author Feedback.
    # It doesn't seem necessary to print out the rubric type in the case of
    # a ReviewResponseMap.  Also, I'm not sure if that would have to be
    # TeamResponseMap for a team assignment.  Someone who understands the
    # situation better could add to the code later.
    if self.map.type.to_s == 'FeedbackResponseMap'
      identifier += "<H2>Feedback from author</H2>"
    end
    if prefix
      identifier += "<B>Reviewer:</B> "+self.map.reviewer.fullname
      str = prefix+"_"+self.id.to_s
    else
      identifier += '<B>'+self.map.get_title+'</B> '+count.to_s+'</B>'
      str = self.id.to_s
    end    
    code = identifier+'&nbsp;&nbsp;&nbsp;<a href="#" name= "review_'+str+'Link" onClick="toggleElement('+"'review_"+str+"','review'"+');return false;">hide review</a><BR/>'
    code += "<B>Last reviewed:</B> "
    if self.updated_at.nil?
      code += "Not available"
    else
      code += self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end
    code += '<div id="review_'+str+'" style=""><BR/><BR/>'
    
    # Test for whether custom rubric needs to be used
    if ((self.map.questionnaire.section.eql? "Custom") && (self.map.type.to_s != 'FeedbackResponseMap'))
      #return top of view
      return code
    end
    # End of custom code
    count = 0
    self.scores.each{
      | reviewScore |
      count += 1
      code += '<big><b>Question '+count.to_s+":</b> <I>"+Question.find_by_id(reviewScore.question_id).txt+"</I></big><BR/><BR/>"
      code += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B></TD></TR>"
      if reviewScore.comments != nil
        code += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + reviewScore.comments.gsub("<","&lt;").gsub(">","&gt;").gsub(/\n/,'<BR/>')
      end
      code += '</TD></TR></TABLE><BR/>'
    }           
    
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ''
    end
    code += "<B>Additional Comment:</B><BR/>"+comment+"</div>"
    return code
  end  
  
  # Computes the total score awarded for a review
  def get_total_score
    total_score = 0
    
    self.map.questionnaire.questions.each{
      | question |
      item = Score.find_by_response_id_and_question_id(self.id, question.id)
      if(item != nil)
        total_score += item.score
      end
    }    
    return total_score        
  end  
  
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)
   mapping = self.map
   instructor = mapping.assignment.instructor 
   Mailer.deliver_message(
     {:recipients => instructor.email,
      :subject => "Expertiza Notification: A review score is outside the acceptable range",
      :body => {        
        :first_name => ApplicationHelper::get_user_first_name(instructor),
        :reviewer_name => mapping.reviewer.fullname,
        :type => "review",
        :reviewee_name => mapping.reviewee.fullname,
        :limit => limit,
        :new_pct => new_pct,
        :avg_pct => avg_pct,
        :types => "reviews",
        :performer => "reviewer",
        :assignment => mapping.assignment,    
        :partial_name => 'limit_notify'
      }
     }
   )         
  end
 
  def delete
    self.scores.each {|score| score.destroy}
    self.destroy
  end

  # Returns the percentage of reviews completed as an integer (0-100)
  # for the given review_object_id
  def self.get_percentage_reviews_completed(id)
    if get_total_reviews_assigned(id) == 0 then 0
    else ((get_total_reviews_completed(id).to_f / get_total_reviews_assigned(id).to_f) * 100).to_i
    end
  end

  # Returns the number of reviewers assigned
  # for the given review_object_id
  def self.get_total_reviews_assigned(id)
    ResponseMap.find_all_by_reviewed_object_id(id).count
  end

  # get_total_reviews_assigned_by_type()
  # Returns the number of reviewers assigned to a particular review object by the type of review
  # Param: id - String (assignment_id etc)
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  def self.get_total_reviews_assigned_by_type(id, type)
    count = 0
    response_maps =  ResponseMap.find_all_by_reviewed_object_id(id)
    response_maps.each { |x| count = count + 1 if x.type == type}
    count
  end

  # Returns the number of reviews completed for a particular review object
  # Param: id - String (assignment_id etc)
  def self.get_total_reviews_completed(id)

    response_count = 0
    response_maps =  ResponseMap.find_all_by_reviewed_object_id(id)
    response_maps.each do |response_map|
      response_count = response_count + 1 unless response_map.response.nil?
    end

    response_count
  end

  # Returns the number of reviews completed for a particular review object by type of review
  # Param: id - String (assignment_id etc)
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  # Param: date - Filter reviews that were not created on this date
  def self.get_total_reviews_completed_by_type_and_date(id, type, date)
    response_count = 0
    response_maps =  ResponseMap.find_all_by_reviewed_object_id(id)
    response_maps.each do |response_map|
      if !response_map.response.nil? and response_map.type == type
        if (response_map.response.created_at.to_datetime.to_date <=> date) == 0 then
          response_count = response_count + 1
        end
      end
    end

    response_count
  end

  # Returns the average of all responses for this review object as an integer (0-100)
  # Param: id - String (assignment_id etc)
  def self.get_average_score(id)
    return 0 if get_total_reviews_assigned(id) == 0

    sum_of_scores = 0
    response_maps =  ResponseMap.find_all_by_reviewed_object_id(id)

    response_maps.each do |response_map|
      if !response_map.response.nil? then
        sum_of_scores = sum_of_scores + response_map.response.get_total_score
      end
    end

    (sum_of_scores / get_total_reviews_completed(id)).to_i
  end

  # Param: id - String (assignment_id etc)
  def self.get_score_distribution(id)
    distribution = Array.new(101, 0)

    response_maps =  ResponseMap.find_all_by_reviewed_object_id(id)
    response_maps.each do |response_map|
      if !response_map.response.nil? then
        score = response_map.response.get_total_score.to_i
        distribution[score] += 1 if score >= 0 and score <= 100
      end
    end

    distribution
  end

  # Function which considers a given assignment
  # and checks if a given review is still valid for score calculation
  # The basic rule is that
  # "A review is INVALID if there was new submission for the assignment
  #  before the most recent review deadline AND THE review happened before that
  #  submission"
  # response - the response whose validity is being checked
  # resubmission_times - submission times of the assignment is descending order
  # latest_review_phase_start_time
  # The function returns true if a review is valid for score calculation
  # and false otherwise
  def is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
    is_valid = true

    # if there was not submission then the response is valid
    if resubmission_times.nil? || latest_review_phase_start_time.nil?
      return is_valid
    end

    resubmission_times.each do | resubmission_time |
      # if the response is after a resubmission that is
      # before the latest_review_phase_start_time (check second condition below)
      # then we are good - the response is valid and we can break
      if (self.updated_at > resubmission_time.resubmitted_at)
        break
      end

      # this means there was a re-submission before the
      # latest_review_phase_start_time and we dont have a response after that
      # so the response is invalid
      if (resubmission_time.resubmitted_at < latest_review_phase_start_time)
        is_valid = false
        break
      end
    end
    is_valid
  end
end
