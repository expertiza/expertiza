#  The Penalty model calculates the penalty of each participant of an assignment and stores it in the Penalties table.


class Penalty < ActiveRecord::Base

    validates_presence_of :user_id
    validates_presence_of :assignment_id
    validates_uniqueness_of :user_id, :scope => :assignment_id
    validates_presence_of :reviewee1_id, :if => (:reviewed1_at?)
    validates_presence_of :reviewee2_id, :if => (:reviewed2_at?)
    validates_presence_of :reviewed1_at, :if => (:reviewed2_at?)
    validates_presence_of :metareviewed1_at, :if =>(:metareviewed2_at?)
    validates_presence_of :metareviewee1_id, :if => (:metareviewed1_at?)
    validates_presence_of :metareviewee2_id, :if => (:metareviewed2_at?)
    validates_numericality_of :assignment_id
    validates_numericality_of :penalty_mins_accumulated, :greater_than_or_equal_to => 0
    validates_numericality_of :penalty_score, :less_than_or_equal_to => 100, :greater_than_or_equal_to => 0

  #def validate
   # errors.add(:penalty_score, "Exceeding a max penalty of 100") if penalty_score.nil? || penalty_score > 100
  #end

# Store the time at which the assignment was submitted by a participant into the Penalties table

def update_submit_times(participant_id)
    partpenalty = Penalty.find_by_participant_id(participant_id)
          partpenalty.submitted_at = Time.now.to_s
    partpenalty.save
    #end
  end

#Calculate the total penalty minutes accumulated by a participant by the end of the assignment and determine the penalty to be imposed.
#Store the penalty minutes and penalty score in the Penalties table

def calculate_penalty(participant_id)


    participantpenalty = Penalty.find_by_participant_id(participant_id)

    get_dates(participantpenalty.participant_id)

     policy = PenaltyPolicy.find(1)

    @submission_deadline_type_id = 1

    @review_deadline_type_id=2
    @metareview_deadline_type_id=5
    @curr_date = Time.now
    @passed_deadline = 0

    @submission_penalty =0
    @submission_delay = 0
    @review1_delay = 0
    @review2_delay = 0
    @review_penalty = 0
    @metareview_penalty = 0
    @metareview1_delay = 0
    @metareview2_delay = 0
    @teammate_review_delay = 0
    @teammate_review_penalty = 0
    @author_feedback_delay = 0
    @author_feedback_penalty = 0

    participantpenalty.penalty_score = 0.0
    participantpenalty.penalty_mins_accumulated = 0.0

    #calculating the penalty for late submissions and no submissions
    #retrieve the due date for submission from the Due_Dates table.

    duedate = DueDate.find_by_deadline_type_id_and_assignment_id(@submission_deadline_type_id, participantpenalty.assignment_id)

    @sub_due_date =   duedate.due_at

    #check if the submission deadline has passed
    @passed_deadline = (@sub_due_date) - (@curr_date)
    if @passed_deadline < 0
       #check if their was any submission made
    if participantpenalty.submitted_at == nil
    #if no, then impose penalty of 50 points.
      @submission_penalty = policy.max_sub_penalty
    else @submission_delay = participantpenalty.submitted_at - @sub_due_date  #calculate the delay in submission
      if @submission_delay > 0
        @submission_penalty = ((@submission_delay/3600).round) * policy.penalty_unit_in_percentage        #compute penalty as a measure of 0.25 percentage per hour
        if @submission_penalty > policy.max_sub_penalty
          @submission_penalty = policy.max_sub_penalty
        end
      else @submission_delay = 0
      end
    end

    end


     #calculating penalty for no reviews or late reviews
    #retrieve the due date for reviews

     duedate = DueDate.find_by_deadline_type_id_and_assignment_id(@review_deadline_type_id, participantpenalty.assignment_id)

      @rev_due_date =   duedate.due_at
    @passed_deadline = (@rev_due_date - @curr_date )
    if @passed_deadline < 0
    if participantpenalty.reviewed1_at == nil
      @review_penalty = policy.max_rev_penalty/2
    else  @review1_delay = participantpenalty.reviewed1_at - @rev_due_date    #calculate the delay in review1
      if @review1_delay > 0
        @review_penalty = ((@review1_delay/3600).round) * policy.penalty_unit_in_percentage        #compute penalty as a measure of 0.25 percentage per hour
        if @review_penalty > policy.max_rev_penalty
          @review_penalty = policy.max_rev_penalty/2
        end
        else @review1_delay = 0
      end
    end
     if participantpenalty.reviewed2_at == nil
      @review_penalty += policy.max_rev_penalty/2
    else  @review2_delay = participantpenalty.reviewed2_at - @rev_due_date    #calculate the delay in review2
      if @review2_delay > 0
        @review_penalty += ((@review2_delay/3600).round) * policy.penalty_unit_in_percentage        #compute penalty as a measure of 0.25 percentage per hour
        if @review_penalty > policy.max_rev_penalty
          @review_penalty = policy.max_rev_penalty
        end
        else @review2_delay = 0
      end
    end
    end

     #raise "#{@review_penalty}"
    #calculating penalty for no metareviews or late metareviews
    #retrieve the due date for metareviews

     duedate = DueDate.find_by_deadline_type_id_and_assignment_id(@metareview_deadline_type_id, participantpenalty.assignment_id)

    @metarev_due_date =   duedate.due_at
    @passed_deadline = (@metarev_due_date - @curr_date )
    if @passed_deadline < 0

    if participantpenalty.metareviewed1_at == nil
      @metareview_penalty = policy.max_rev_penalty/2
    else  @metareview1_delay = participantpenalty.metareviewed1_at - @metarev_due_date    #calculate the delay in metareview1
      if @metareview1_delay > 0
        @metareview_penalty = ((@metareview1_delay/3600).round) * policy.penalty_unit_in_percentage        #compute penalty as a measure of 0.25 percentage per hour
        if @metareview_penalty > policy.max_rev_penalty
          @metareview_penalty = policy.max_rev_penalty/2
        end
        else @metareview1_delay = 0
      end
    end
    if participantpenalty.metareviewed2_at == nil
      @metareview_penalty += policy.max_rev_penalty/2
    else  @metareview2_delay = participantpenalty.metareviewed2_at - @metarev_due_date    #calculate the delay in metareview2
      if @metareview2_delay > 0
        @metareview_penalty += ((@metareview2_delay/3600).round) * policy.penalty_unit_in_percentage        #compute penalty as a measure of 0.25 percentage per hour
        if @metareview_penalty > policy.max_rev_penalty
          @metareview_penalty = policy.max_rev_penalty
        end
        else @metareview2_delay = 0
      end
    end

    #calculate penalty for late teammate reviews and no teammate reviews
    if participantpenalty.teammate_review_at == nil
      @teammate_review_penalty = policy.max_rev_penalty
    else  @teammate_review_delay = participantpenalty.teammate_review_at - @metarev_due_date    #calculate the delay in teammate review
      if @teammate_review_delay > 0
        @teammate_review_penalty = ((@teammate_review_delay/3600).round) * policy.penalty_unit_in_percentage        #compute penalty as a measure of 0.25 percentage per hour
        if @teammate_review_penalty > policy.max_rev_penalty
          @teammate_review_penalty = policy.max_rev_penalty
        end
        else @teammate_review_delay = 0
      end
    end
    end
    #calculate penalty for late author feedbacks and no feedbacks
    @passed_deadline = (@rev_due_date - @curr_date )
    if @passed_deadline < 0
    if participantpenalty.author_feedback_at == nil
      @author_feedback_penalty = policy.max_rev_penalty
    else  @author_feedback_delay = participantpenalty.author_feedback_at - @rev_due_date   #calculate the delay in author_feedback
      if @author_feedback_delay > 0
        @author_feedback_penalty = ((@author_feedback_delay/3600).round) * policy.penalty_unit_in_percentage        #compute penalty as a measure of 0.25 percentage per hour
        if @author_feedback_penalty > policy.max_rev_penalty
          @author_feedback_penalty = policy.max_rev_penalty
        end
        else @author_feedback_delay = 0
      end
    end
    end

    #calculate the total penalty minutes accumulated
    participantpenalty.penalty_mins_accumulated  = @submission_delay + @review1_delay + @review2_delay + @metareview1_delay + @metareview2_delay + @teammate_review_delay + @author_feedback_delay

    #calculate the total penalty score accumulated
    participantpenalty.penalty_score = @submission_penalty + @review_penalty + @metareview_penalty + @teammate_review_penalty + @author_feedback_penalty


    participantpenalty.save

    return participantpenalty.penalty_score
  end

  #retrieve the dates when the participant has performed various tasks like Review, Metareview, Author Feedback, Teammate Review
  def get_dates(participant_id)
    participantpenalty = Penalty.find_by_participant_id(participant_id)


    #check if the participant has performed the first mandatory review. If yes,get the date of the review
    if participantpenalty.reviewed1_at== nil
          response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'TeamReviewResponseMap')
          if response_map_id.nil?
            response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'ParticipantReviewResponseMap')
          end
          if !response_map_id.nil?
             response_at = Response.find_by_map_id(response_map_id.id)
            participantpenalty.reviewee1_id = response_map_id.reviewee_id
            participantpenalty.reviewed1_at = response_at.created_at
            participantpenalty.save
          end
    else
  #check if the participant has performed the second mandatory review. If yes, get the date of the review
      if participantpenalty.reviewed2_at == nil
          response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'TeamReviewResponseMap', :conditions => ['reviewee_id !=?', participantpenalty.reviewee1_id])
         if response_map_id.nil?
            response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'ParticipantReviewResponseMap')
          end
          if !response_map_id.nil?
            response_at = Response.find_by_map_id(response_map_id.id)
            participantpenalty.reviewee2_id = response_map_id.reviewee_id
            participantpenalty.reviewed2_at = response_at.created_at
            participantpenalty.save
          end
      end
    end

    #check if the participant has performed the first mandatory metareview. If yes, get the date of the review
    if participantpenalty.metareviewed1_at== nil
              response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'MetareviewResponseMap')
              if !response_map_id.nil?
                response_at = Response.find_by_map_id(response_map_id.id)
                participantpenalty.metareviewee1_id = response_map_id.reviewee_id
                participantpenalty.metareviewed1_at = response_at.created_at
                participantpenalty.save
              end
    else
      #check if the participant has performed the second mandatory metareview. If yes, get the date of the review
          if participantpenalty.metareviewed2_at == nil
           response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'MetareviewResponseMap', :conditions => ['reviewee_id !=?', participantpenalty.metareviewee1_id])
           if !response_map_id.nil?
              response_at = Response.find_by_map_id(response_map_id.id)
              participantpenalty.metareviewee2_id = response_map_id.reviewee_id
              participantpenalty.metareviewed2_at = response_at.created_at
              participantpenalty.save
             end
          end
        end

    #check if the participant has performed the teammmate review. If yes, get the date of the review
    if participantpenalty.teammate_review_at == nil
           response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'TeammateReviewResponseMap')
           if !response_map_id.nil?
              response_at = Response.find_by_map_id(response_map_id.id)
              if !response_at.nil?
                participantpenalty.teammate_review_at = response_at.created_at
                participantpenalty.save
              end
             end
          end

    #check if the participant has performed the author feedback. If yes, get the date of the feedback.
    if participantpenalty.author_feedback_at == nil
            response_map_id = ResponseMap.find_by_reviewer_id_and_type(participantpenalty.participant_id,'FeedbackResponseMap')
            if !response_map_id.nil?
              response_at = Response.find_by_map_id(response_map_id.id)
              if !response_at.nil?
                participantpenalty.teammate_review_at = response_at.created_at
                participantpenalty.save
              end
              end
    end

    participantpenalty.save
  end
end
