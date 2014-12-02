class GradesController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper

  $submission_ddl_type = 1             # global variables submission_ddl_type
  $review_ddl_type = 2                 # global variables review_ddl_type
  $meta_review_ddl_type = 5            # global variables meta_review_ddl_type

  def action_allowed?
    case params[:action]
    when 'grades_show'
      current_role_name.eql? 'Student'
    when 'show_reviews'
        true
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name
    end
  end

  #the view grading report provides the instructor with an overall view of all the grades for
  #an assignment. It lists all participants of an assignment
  #It also gives a final score, which is an average of all the reviews and greatest difference
  #in the scores of all the reviews.
  def view
    @assignment = Assignment.find(params[:id])
    @questions = {}
    questionnaires = @assignment.questionnaires_with_questions
    questionnaires.each do |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    end

    @scores = @assignment.get_scores(@questions)
    calculate_all_penalties(@assignment.id)
  end

  #the show_reviews action lists all the reviews they received.
  def show_reviews
    partial='grades/'+params[:path]
    prefix=params[:prefix]
    @score=Hash.new
    @score[:partial]= partial
    @score[:prefix] = prefix
    @score[:assessments]=Array.new
    params[:score][:assessments].each do |assessment|
        @score[:assessments]<<Response.find(assessment)
    end
    @score[:scores]=params[:score][:scores]
    participant=AssignmentParticipant.find(params[:participant])
    @score[:participant] = participant
    assignment = participant.assignment
    @score[:assignment] = assignment
    @questions = {}
    questionnaires = assignment.questionnaires
    questionnaires.each do |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    end
  end


  def grades_show
    #deleted unnecessary instance variables
    @participant = AssignmentParticipant.find(params[:id])
    return if redirect_when_disallowed
    @assignment = @participant.assignment
    @questions = {}
    questionnaires = @assignment.questionnaires
    questionnaires.each do |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    end

    rmaps = ParticipantReviewResponseMap.where(reviewee_id: @participant.id, reviewed_object_id: @participant.assignment.id)
    rmaps.find_each do |rmap|
      rmap.update_attribute :notification_accepted, true
    end

    rmaps = ParticipantReviewResponseMap.where reviewer_id: @participant.id, reviewed_object_id: @participant.parent_id
    rmaps.find_each do |rmap|
      mmaps = MetareviewResponseMap.where reviewee_id: rmap.reviewer_id, reviewed_object_id: rmap.map_id
      mmaps.find_each do |mmap|
        mmap.update_attribute :notification_accepted, true
      end
    end

    @topic = @participant.topic
    @pscore = @participant.get_scores(@questions)
    @stage = @participant.assignment.get_current_stage(@participant.topic_id)

    calculate_all_penalties(@assignment.id)
  end


  def edit
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    @questions = Hash.new
    questionnaires = @assignment.questionnaires
    questionnaires.each {
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    }

    @scores = @participant.scores(@questions)
  end

  def instructor_review
    participant = AssignmentParticipant.find(params[:id])

    reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id:  participant.assignment.id).first
    if reviewer.nil?
      reviewer = AssignmentParticipant.create(:user_id => session[:user].id, :parent_id => participant.assignment.id)
      reviewer.set_handle()
    end

    review_exists = true

    if participant.assignment.team_assignment?
      reviewee = participant.team
      review_mapping = TeamReviewResponseMap.where(reviewee_id: reviewee.id, reviewer_id:  reviewer.id).first

      if review_mapping.nil?
        review_exists = false
        if participant.assignment.team_assignment?
          review_mapping = TeamReviewResponseMap.create(:reviewee_id => participant.team.id, :reviewer_id => reviewer.id, :reviewed_object_id => participant.assignment.id)
        end
        review = Response.find_by_map_id(review_mapping.map_id)

        unless review_exists
          redirect_to :controller => 'response', :action => 'new', :id => review_mapping.map_id, :return => "instructor"
        else
          redirect_to :controller => 'response', :action => 'edit', :id => review.id, :return => "instructor"
        end
      end
    end
  end

  def open
    send_file(params['fname'], :disposition => 'inline')
  end



    # the grading conflict email form provides the instructor a way of emailing
    # the reviewers of a submission if he feels one of the reviews was unfair or inaccurate.
    def conflict_email
      if session[:user].role_id !=6
        instructor = session[:user]
      else
        instructor = Ta.get_my_instructor(session[:user].id)
      end
      recipient=User.find(params[:reviewer_id])

      participant = AssignmentParticipant.find(params[:participant_id])
      assignment=Assignment.find(participant.parent_id)
      score=params[:score]
      ConflictMailer.send_conflict_email(instructor,recipient,assignment,score).deliver

      #respond with ajax, Alert that email has been successfully sent
      respond_to do |format|
        format.js
      end

    end


    def update
      participant = AssignmentParticipant.find(params[:id])
      total_score = params[:total_score]
      if sprintf("%.2f", total_score) != params[:participant][:grade]
        participant.update_attribute(:grade, params[:participant][:grade])
        if participant.grade.nil?
          message = "The computed score will be used for "+participant.user.name
        else
          message = "A score of "+params[:participant][:grade]+"% has been saved for "+participant.user.name
        end
      end
      flash[:note] = message
      redirect_to :action => 'edit', :id => params[:id]
    end

    private


    def redirect_when_disallowed
      # For author feedback, participants need to be able to read feedback submitted by other teammates.
      # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
      ## This following code was cloned from response_controller.

      #ACS Check if team count is more than 1 instead of checking if it is a team assignment
      if @participant.assignment.max_team_size > 1
        team = @participant.team
        if (!team.nil?)
          unless team.has_user session[:user]
            redirect_to '/denied?reason=You are not on the team that wrote this feedback'
            return true
          end
        end
      else
        reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id: @participant.assignment.id).first
        return true unless current_user_id?(reviewer.user_id)
      end
      return false
    end



  def calculate_all_penalties(assignment_id)
        @all_penalties = {}
        @assignment = Assignment.find(assignment_id)
        unless @assignment.is_penalty_calculated
            calculate_for_participants = true
            @assignment.update_attribute(:is_penalty_calculated, true)
        end
        Participant.where(parent_id: assignment_id).each do |participant|
            penalties = calculate_penalty(participant.id)
            @total_penalty = 0
            if(penalties[:submission] != 0 || penalties[:review] != 0 || penalties[:meta_review] != 0)
              #simplify the if loop
                penalties[:submission] = 0 if penalties[:submission].nil?
                penalties[:review] = 0 if penalties[:review].nil?
                penalties[:meta_review] = 0 if penalties[:meta_review].nil?
                @total_penalty = (penalties[:submission] + penalties[:review] + penalties[:meta_review])
                l_policy = LatePolicy.find(@assignment.late_policy_id)
                @total_penality=[l_policy.max_penalty,@total_penality].min #using max/min function rather than using if loop
                deadline_type=[$submission_ddl_type,$review_ddl_type,$meta_review_ddl_type]#submission deadline type,review deadline type,meta_review_deadline type
                penalty_type=[:submission,:review,:meta_review]
                if calculate_for_participants
                    for i in 0..2
                        penalty_attr={:deadline_type_id =>deadline_type[i],:participant_id => @participant.id, :penalty_points => penalties[penalty_type[i]]}
                        CalculatedPenalty.create(penalty_attr)
                    end
                end
            end
            @all_penalties[participant.id] = {}
            for i in 0..2
                @all_penalties[participant.id][:penalty_type[i]] = penalties[:penalty_type[i]]
            end
            @all_penalties[participant.id][:total_penalty] = @total_penalty
        end
    end
end
