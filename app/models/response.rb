class Response < ActiveRecord::Base
  #belongs_to :map, :class_name => 'ResponseMap', :foreign_key => 'map_id'   #ResponseMap dependency removed
  has_many :scores, :class_name => 'Score', :foreign_key => 'response_id', :dependent => :destroy
  belongs_to :reviewer, :class_name => 'Participant', :foreign_key => 'reviewer_id'
  has_many :metareview_response, :class_name => 'MetareviewResponse', :foreign_key => 'reviewed_object_id'   #changed MetareviewResponseMap -> MetareviewResponse
  #before_create :add_dummy_map_id  #not required

  #def add_dummy_map_id               #changed find_by_map_id to find_by_id
  #  self.map_id = Response.maximum(:map_id) + 1
  #end

  def map
    self
  end

  def team_has_user?(user)
    reviewer.team.has_user user
  end

  def display_as_html(prefix = nil, count = nil, file_url = nil)
    identifier = ""
    # The following three lines print out the type of rubric before displaying
    # feedback.  Currently this is only done if the rubric is Author Feedback.
    # It doesn't seem necessary to print out the rubric type in the case of
    # a ReviewResponse.  Also, I'm not sure if that would have to be
    # TeamResponse for a team assignment.  Someone who understands the
    # situation better could add to the code later.
    if self.map.type.to_s == 'FeedbackResponse'  #type changed from FeedbackResponseMap to FeedbackResponse
      identifier += "<H2>Feedback from author</H2>"
    end
    if prefix
      identifier += "<B>Reviewer:</B> #{count}" #+self.map.reviewer.fullname
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
    if ((self.map.questionnaire.section.eql? "Custom") && (self.map.type.to_s != 'FeedbackResponse'))   #type changed from FeedbackResponseMap to FeedbackResponse
      #return top of view
      return code
    end
    # End of custom code
    count = 0
    #self.scores.each {
    Score.find_all_by_response_id(self.response_id).each {
        |reviewScore|
      count += 1
      code += '<big><b>Question '+count.to_s+":</b> <I>"+Question.find_by_id(reviewScore.question_id).txt+"</I></big><BR/><BR/>"
      code += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B></TD></TR>"
      if reviewScore.comments != nil
        code += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + reviewScore.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
      end
      code += '</TD></TR></TABLE><BR/>'
    }

    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p', '').gsub(/\n/, '<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ''
    end
    code += "<B>Additional Comment:</B><BR/>"+comment+"</div>"
    return code.html_safe
  end

  # Computes the total score awarded for a review
  def get_total_score
    scores.map(&:score).sum
  end

  #Generate an email to the instructor when a new review exceeds the allowed difference
  #ajbudlon, nov 18, 2008
  def notify_on_difference(new_pct, avg_pct, limit)
    mapping = self.map
    instructor = mapping.assignment.instructor
    begin
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
    rescue
    end
  end

  def delete
    self.scores.each { |score| score.destroy }
    self.destroy
  end

  #bug fixed
  # Returns the average score for this response as an integer (0-100)
  def get_average_score()
    if get_maximum_score != 0 then
      ((get_total_score.to_f / get_maximum_score.to_f) * 100).to_i
    else
      0
    end
  end

  # Returns the maximum possible score for this response
  def get_maximum_score()
    max_score = 0

    self.scores.each { |score| max_score = max_score + score.question.questionnaire.max_question_score }

    max_score
  end

  # Returns the total score from this response
  def get_alternative_total_score()
    # TODO The method get_total_score() above does not seem correct.  Replace with this method.
    total_score = 0

    self.scores.each { |score| total_score = total_score + score.score }

    total_score
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

    resubmission_times.each do |resubmission_time|
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

  #########################################################################################################################3
  #Methods below have been copied from ResponseMap class, the purpose to do this :   we don't loose the metods/actions in ResponseMap , as ResponseMap is replaced by Response so the
  #methods calls don't have to be invalid.

  def response_id
    self['id']
  end

  # return latest versions of the responses
  def self.get_assessments_for(participant)
    responses = Array.new

    if participant

      @array_sort=Array.new
      @sort_to=Array.new

      #get all the versions
      maps = find_all_by_reviewee_id(participant.id)
      maps.each { |map|
        if map.response
          @all_resp=Response.all
          for element in @all_resp
            if (element.id == map.id)    #changed map_id to id
              @array_sort << element
            end
          end
          #sort all versions in descending order and get the latest one.
          @sort_to=@array_sort.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
          responses << @sort_to[0]
          @array_sort.clear
          @sort_to.clear
        end
      }
      responses.sort! { |a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    return responses
  end

  # return latest versions of the response given by reviewer
  def self.get_reviewer_assessments_for(participant, reviewer)
    map = find_all_by_reviewee_id_and_reviewer_id(participant.id, reviewer.id)
    return Response.find_all_by_id(map).sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }[0]   #find_all_by_map_id changed to find_all_by_id
  end

  # Placeholder method, override in derived classes if required.
  def get_all_versions()
    return []
  end

  def delete(force = nil)
    self.destroy
  end

  def show_review()
    return nil
  end

  def show_feedback()
    return nil
  end

  # Evaluates whether this response_map was metareviewed by metareviewer
  # @param[in] metareviewer AssignmentParticipant object
  def metareviewed_by?(metareviewer)
    MetareviewResponse.find_all_by_reviewee_id_and_reviewer_id_and_reviewed_object_id(self.reviewer.id, metareviewer.id, self.id).count() > 0    #changed MetareviewResponseMap to MetareviewResponse
  end

  # Assigns a metareviewer to this review (response)
  # @param[in] metareviewer AssignmentParticipant object
  def assign_metareviewer(metareviewer)
    MetareviewResponse.create(:reviewed_object_id => self.id,                        #changed MetareviewResponseMap to MetareviewResponse
                                 :reviewer_id => metareviewer.id, :reviewee_id => reviewer.id)
  end

  def self.delete_mappings(mappings, force=nil)
    failedCount = 0
    mappings.each {
        |mapping|
      begin
        mapping.delete(force)
      rescue
        failedCount += 1
      end
    }
    return failedCount
  end

  def self.find(*args)
    if args.length == 1
      Response.find_by_id(args.first)   #changed find_by_map_id to find_by_id
    else
      super
    end
  end

  def self.find_by_id(*args)
    Response.find_by_id(args.first)   #changed find_by_map_id to find_by_id
  end

  def response
    self
  end

  require 'analytic/response_analytic'
  include ResponseAnalytic
end
