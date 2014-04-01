class GradesController < ApplicationController
  use_google_charts
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper

  def action_allowed?
    case params[:action]
    when 'view_my_scores'
      current_role_name.eql? 'Student'
    when 'all_scores'
        current_role_name.eql? 'Student'
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name

    end
   true
  end

  # method to return scores of user for all assignments
  def all_scores
    @scores = Hash.new

    # Single query to return all scores for user
    st = ActiveRecord::Base.connection.raw_connection.prepare("select assignments.name, questionnaire_type, avg(score), min(score), max(score) from
          (select r.id as response_id, team_id, tu.user_id as user_id, (SUM(weight*score)*100)/(sum(weight)*max_question_score) as score, parent_id as assignment_id, qs.type as questionnaire_type from scores s ,responses r, response_maps rm, questions q, questionnaires qs , teams_users tu , teams t
           WHERE  rm.id = r.map_id AND r.id=s.response_id AND q.id = s.question_id AND qs.id = q.questionnaire_id    AND tu.team_id = rm.reviewee_id   AND tu.team_id = t.id group by r.id
          ) as participant_score_aggregate, assignments where assignments.id = participant_score_aggregate.assignment_id
          and user_id = ? group by assignment_id, questionnaire_type")

    # Execute query and pass current user id
    results = st.execute(current_user.id)

    # Loop through results to populate scores hash
    # row[0] is assignment name
    # row[1] is questionnaire type
    # row[2] is avg
    # row[3] is min
    # row[4] is max

    results.each do |row|
      @scores[row[0].to_s.to_sym] = Hash.new
      @scores[row[0].to_s.to_sym][row[1].to_s.to_sym] = Hash.new
      @scores[row[0].to_s.to_sym][row[1].to_s.to_sym][:avg] = row[2].to_f.round(2)
      @scores[row[0].to_s.to_sym][row[1].to_s.to_sym][:min] = row[3].to_f.round(2)
      @scores[row[0].to_s.to_sym][row[1].to_s.to_sym][:max] = row[4].to_f.round(2)
    end
  end
  def view_course_scores

    # Create empty scores hash
    @scores = Hash.new

    @scores[params[:course_id]]= Hash.new

    course_assignments = Array.new
    # Get all the assignments for this course
    course_assignments = Assignment.find_all_by_course_id(params[:course_id])

    # Hash creation begins. A hash is created to have the same structure as required by the view
    # This hash is not created after the query according to the resultset because
    # the query only returns results for participants who got responses and scores.
    # We want an empty placeholder for participants that have no scores.
    # Loop through the course assignments array
    course_assignments.each do |assignment|
      @scores[params[:course_id]][assignment.name.to_sym] = Hash.new

      # Loop through all the participants of this assignment
      assignment.participants.each do |participant|

        # Get the user name of the participant from the user id
        participant_name = User.find(participant.user_id).name

        @scores[params[:course_id]][assignment.name.to_sym][participant_name.to_s.to_sym]=Hash.new

        # Loop through the assignment questionnaires
        assignment.questionnaires.each do |questionnaire|
          @scores[params[:course_id]][assignment.name.to_sym][participant_name.to_s.to_sym][questionnaire.symbol] = Hash.new
          @scores[params[:course_id]][assignment.name.to_sym][participant_name.to_s.to_sym][questionnaire.symbol][:scores] = Hash.new
          @scores[params[:course_id]][assignment.name.to_sym][participant_name.to_s.to_sym][questionnaire.symbol][:scores][:avg] = nil
          @scores[params[:course_id]][assignment.name.to_sym][participant_name.to_s.to_sym][questionnaire.symbol][:scores][:min] = nil
          @scores[params[:course_id]][assignment.name.to_sym][participant_name.to_s.to_sym][questionnaire.symbol][:scores][:max] = nil
        end
      end
    end
    # Hash creation completed

    # Single sql query
    st = ActiveRecord::Base.connection.raw_connection.prepare("select assignments.name, user_id, questionnaire_type, avg(score), min(score), max(score) from
  (select r.id as response_id, team_id, u.name as user_id, (SUM(weight*score)*100)/(sum(weight)*max_question_score) as score, t.parent_id as assignment_id, qs.type as questionnaire_type from scores s ,responses r, response_maps rm, questions q, questionnaires qs , users u, teams_users tu , teams t
   WHERE  rm.id = r.map_id AND r.id=s.response_id AND q.id = s.question_id AND qs.id = q.questionnaire_id    AND tu.team_id = rm.reviewee_id   AND tu.team_id = t.id AND tu.user_id=u.id group by r.id
  ) as participant_score_aggregate, assignments where assignments.id = participant_score_aggregate.assignment_id
  and assignments.course_id = ? group by assignment_id, questionnaire_type")
    # Run the sql query with the course id as parameter
    results = st.execute(params[:course_id])

    # Loop through the results
    # row[0] is assignment name
    # row[1] is user id
    # row[2] is questionnaire typ
    # row[3] is avg
    # row[4] is min
    # row[5] is max
    results.each do |row|
      # Set the type of questionnaire
      case row[2].to_sym
        when :ReviewQuestionnaire
          quetionnaire_type= :review
        when :AuthorFeedbackQuestionnaire
          quetionnaire_type= :feedback
        when :MetareviewQuestionnaire
          quetionnaire_type= :metareview
        when :TeammateReviewQuestionnaire
          quetionnaire_type= :teammate
      end

      # Set the avg, min and max scores
      @scores[params[:course_id]][row[0].to_s.to_sym][row[1].to_s.to_sym][quetionnaire_type][:scores][:avg]=row[3].to_f.round(2)
      @scores[params[:course_id]][row[0].to_s.to_sym][row[1].to_s.to_sym][quetionnaire_type][:scores][:min]=row[4].to_f.round(2)
      @scores[params[:course_id]][row[0].to_s.to_sym][row[1].to_s.to_sym][quetionnaire_type][:scores][:max]=row[5].to_f.round(2)
    end

    @scores
  end

  #the view grading report provides the instructor with an overall view of all the grades for
  #an assignment. It lists all participants of an assignment and all the reviews they received.
  #It also gives a final score, which is an average of all the reviews and greatest difference
  #in the scores of all the reviews.
  def view
    @assignment = Assignment.find(params[:id])
    @questions = Hash.new
    questionnaires = @assignment.questionnaires
    questionnaires.each {
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    }
    @scores = @assignment.get_scores(@questions)
    calculate_all_penalties(@assignment.id)
  end

  def view_my_scores

    @participant = AssignmentParticipant.find(params[:id])

    @average_score_results = Array.new
    @average_score_results = ScoreCache.get_class_scores(@participant.id)

    @statistics = Array.new
    @average_score_results.each { |x|
      @statistics << x
    }

    @average_reviews = ScoreCache.get_reviews_average(@participant.id)
    @average_metareviews = ScoreCache.get_metareviews_average(@participant.id)

    @my_reviews = ScoreCache.my_reviews(@participant.id)

    @my_metareviews = ScoreCache.my_metareviews(@participant.id)

    return if redirect_when_disallowed
    @assignment = @participant.assignment
    @questions = Hash.new
    questionnaires = @assignment.questionnaires
    questionnaires.each {
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    }
    ## When user clicks on the notification, it should go away
    #deleting all review notifications
    rmaps = ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(@participant.id, @participant.assignment.id)
    for rmap in rmaps
      rmap.notification_accepted = true
      rmap.save
    end
    ############

    #deleting all metareview notifications
    rmaps = ParticipantReviewResponseMap.find_all_by_reviewer_id_and_reviewed_object_id(@participant.id, @participant.parent_id)
    for rmap in rmaps
      mmaps = MetareviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(rmap.reviewer_id, rmap.map_id)
      if !mmaps.nil?
        for mmap in mmaps
          mmap.notification_accepted = true
          mmap.save
        end
      end
    end

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

    reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, participant.assignment.id)
    if reviewer.nil?
      reviewer = AssignmentParticipant.create(:user_id => session[:user].id, :parent_id => participant.assignment.id)
      reviewer.set_handle()
    end

    review_exists = true

    if participant.assignment.team_assignment?
      reviewee = participant.team
      review_mapping = TeamReviewResponseMap.find_by_reviewee_id_and_reviewer_id(reviewee.id, reviewer.id)

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


  def send_grading_conflict_email
    email_form = params[:mailer]
    assignment = Assignment.find(email_form[:assignment])
    recipient = User.find(:first, :conditions => ["email = ?", email_form[:recipients]])

    body_text = email_form[:body_text]
    body_text["##[recipient_name]"] = recipient.fullname
    body_text["##[recipients_grade]"] = email_form[recipient.fullname+"_grade"]+"%"
    body_text["##[assignment_name]"] = assignment.name

    Mailer.deliver_message(
      {:recipients => email_form[:recipients],
       :subject => email_form[:subject],
       :from => email_form[:from],
       :body => {
         :body_text => body_text,
         :partial_name => "grading_conflict"
       }
    }
    )

    flash[:notice] = "Your email to " + email_form[:recipients] + " has been sent. If you would like to send an email to another student please do so now, otherwise click Back"
    redirect_to :action => 'conflict_email_form',
      :assignment => email_form[:assignment],
      :author => email_form[:author]
    end

    # the grading conflict email form provides the instructor a way of emailing
    # the reviewers of a submission if he feels one of the reviews was unfair or inaccurate.
    def conflict_notification
      if session[:user].role_id !=6
        @instructor = session[:user]
      else
        @instructor = Ta.get_my_instructor(session[:user].id)
      end
      @participant = AssignmentParticipant.find(params[:id])
      @assignment = Assignment.find(@participant.parent_id)


      @questions = Hash.new
      questionnaires = @assignment.questionnaires
      questionnaires.each {
        |questionnaire|
        @questions[questionnaire.symbol] = questionnaire.questions
      }

      @reviewers_email_hash = Hash.new

      @caction = "view"
      @submission = params[:submission]
      if @submission == "review"
        @caction = "view_review"
        @symbol = "review"
        process_response("Review", "Reviewer", @participant.reviews, "ReviewQuestionnaire")
      elsif @submission == "review_of_review"
        @symbol = "metareview"
        process_response("Metareview", "Metareviewer", @participant.metareviews, "MetareviewQuestionnaire")
      elsif @submission == "review_feedback"
        @symbol = "feedback"
        process_response("Feedback", "Author", @participant.feedback, "AuthorFeedbackQuestionnaire")
      elsif @submission == "teammate_review"
        @symbol = "teammate"
        process_response("Teammate Review", "Reviewer", @participant.teammate_reviews, "TeammateReviewQuestionnaire")
      end

      @subject = " Your "+@collabel.downcase+" score for " + @assignment.name + " conflicts with another "+@rowlabel.downcase+"'s score."
      @body = get_body_text(params[:submission])

    end


    def update
      participant = AssignmentParticipant.find(params[:id])
      total_score = params[:total_score]
      if sprintf("%.2f", total_score) != params[:participant][:grade]
        participant.update_attribute('grade', params[:participant][:grade])
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

    def process_response(collabel, rowlabel, responses, questionnaire_type)
      @collabel = collabel
      @rowlabel = rowlabel
      @reviews = responses
      @reviews.each {
        |response|
        user = response.map.reviewer.user
        @reviewers_email_hash[user.fullname.to_s+" <"+user.email.to_s+">"] = user.email.to_s
      }
      @reviews.sort! { |a, b| a.map.reviewer.user.fullname <=> b.map.reviewer.user.fullname }
      @questionnaire = @assignment.questionnaires.find_by_type(questionnaire_type)
      @max_score, @weight = @assignment.get_max_score_possible(@questionnaire)
    end

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
        reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, @participant.assignment.id)
        return true unless current_user_id?(reviewer.user_id)
      end
      return false
    end

    def get_body_text(submission)
      if submission
        role = "reviewer"
        item = "submission"
      else
        role = "metareviewer"
        item = "review"
      end
      "Hi ##[recipient_name],

        You submitted a score of ##[recipients_grade] for assignment ##[assignment_name] that varied greatly from another "+role+"'s score for the same "+item+".

        The Expertiza system has brought this to my attention."
    end

    def calculate_all_penalties(assignment_id)
      @all_penalties = Hash.new
      @assignment = Assignment.find_by_id(assignment_id)
      participant_count = 0
      calculate_for_participant = false
      if @assignment.is_penalty_calculated == false
        calculate_for_participants = true
      end
      Participant.find_all_by_parent_id(assignment_id).each do |participant|
        if participant.type=='AssignmentParticipant'
        penalties = calculate_penalty(participant.id)
        @total_penalty =0
        if(penalties[:submission] != 0 || penalties[:review] != 0 || penalties[:meta_review] != 0)
          if(penalties[:submission].nil?)
            penalties[:submission]=0
          end
          if(penalties[:review].nil?)
            penalties[:review]=0
          end
          if(penalties[:meta_review].nil?)
            penalties[:meta_review]=0
          end
          @total_penalty = (penalties[:submission] + penalties[:review] + penalties[:meta_review])
          l_policy = LatePolicy.find_by_id(@assignment.late_policy_id)
          if(@total_penalty > l_policy.max_penalty)
            @total_penalty = l_policy.max_penalty
          end
          if calculate_for_participants == true
            penalty_attr1 = {:deadline_type_id => 1,:participant_id => @participant.id, :penalty_points => penalties[:submission]}
            CalculatedPenalty.create(penalty_attr1)

            penalty_attr2 = {:deadline_type_id => 2,:participant_id => @participant.id, :penalty_points => penalties[:review]}
            CalculatedPenalty.create(penalty_attr2)

            penalty_attr3 = {:deadline_type_id => 5,:participant_id => @participant.id, :penalty_points => penalties[:meta_review]}
            CalculatedPenalty.create(penalty_attr3)
          end
        end
        @all_penalties[participant.id] = Hash.new
        @all_penalties[participant.id][:submission] = penalties[:submission]
        @all_penalties[participant.id][:review] = penalties[:review]
        @all_penalties[participant.id][:meta_review] = penalties[:meta_review]
        @all_penalties[participant.id][:total_penalty] = @total_penalty
       end
      end
      if @assignment.is_penalty_calculated == false
        @assignment.update_attribute(:is_penalty_calculated, true)
      end
    end




  end