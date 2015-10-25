class GradesController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper

  def action_allowed?
    case params[:action]
    when 'view_my_scores'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and are_needed_authorizations_present?
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  #the view grading report provides the instructor with an overall view of all the grades for
  #an assignment. It lists all participants of an assignment and all the reviews they received.
  #It also gives a final score, which is an average of all the reviews and greatest difference
  #in the scores of all the reviews.
  def view
    @assignment = Assignment.find(params[:id])
    @questions = {}
    questionnaires = @assignment.questionnaires_with_questions

    if @assignment.varying_rubrics_by_round?
      questionnaires.each {
        |questionnaire|
        round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(@assignment.id, questionnaire.id).used_in_round
        if(round!=nil)
          questionnaire_symbol = (questionnaire.symbol.to_s+round.to_s).to_sym
        else
          questionnaire_symbol = questionnaire.symbol
        end
        @questions[questionnaire_symbol] = questionnaire.questions
      }
    else      #if this assignment does not have "varying rubric by rounds" feature
      questionnaires.each {
        |questionnaire|
        @questions[questionnaire.symbol] = questionnaire.questions
      }
    end
    @scores = @assignment.scores(@questions)
    averages = calculate_average_vector(@assignment.scores(@questions))
    @average_chart =  bar_chart(averages,300,100,5)
    @avg_of_avg = mean(averages)
    calculate_all_penalties(@assignment.id)
  end

  def view_my_scores
    @participant = AssignmentParticipant.find(params[:id])
    @team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
    return if redirect_when_disallowed
    @assignment = @participant.assignment
    @questions = {} # A hash containing all the questions in all the questionnaires used in this assignment
    questionnaires = @assignment.questionnaires
    questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id:questionnaire.id).first.used_in_round
      if(round!=nil)
        questionnaire_symbol = (questionnaire.symbol.to_s+round.to_s).to_sym
      else
        questionnaire_symbol = questionnaire.symbol
      end
      @questions[questionnaire_symbol] = questionnaire.questions
    end

    #@pscore has the newest versions of response for each response map, and only one for each response map (unless it is vary rubric by round)
    @pscore = @participant.scores(@questions)
    make_chart
    @topic_id = SignedUpTeam.topic_id(@participant.assignment.id, @participant.user_id)
    @stage = @participant.assignment.get_current_stage(@topic_id)
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
      review_mapping = ReviewResponseMap.where(reviewee_id: reviewee.id, reviewer_id:  reviewer.id).first

      if review_mapping.nil?
        review_exists = false
        review_mapping = ReviewResponseMap.create(:reviewee_id => participant.team.id, :reviewer_id => reviewer.id, :reviewed_object_id => participant.assignment.id)
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
    recipient = User.where(["email = ?", email_form[:recipients]]).first

    body_text = email_form[:body_text]
    body_text["##[recipient_name]"] = recipient.fullname
    body_text["##[recipients_grade]"] = email_form[recipient.fullname+"_grade"]+"%"
    body_text["##[assignment_name]"] = assignment.name

    Mailer.sync_message(
      {:recipients => email_form[:recipients],
       :subject => email_form[:subject],
       :from => email_form[:from],
       :body => {
         :body_text => body_text,
         :partial_name => "grading_conflict"
       }
       }
    ).deliver

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
      reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id: @participant.assignment.id).first
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
    @all_penalties = {}
    @assignment = Assignment.find(assignment_id)
    unless @assignment.is_penalty_calculated
      calculate_for_participants = true
    end
    Participant.where(parent_id: assignment_id).each do |participant|
      penalties = calculate_penalty(participant.id)
      @total_penalty = 0
      if(penalties[:submission] != 0 || penalties[:review] != 0 || penalties[:meta_review] != 0)
        unless penalties[:submission]
          penalties[:submission] = 0
        end
        unless penalties[:review]
          penalties[:review] = 0
        end
        unless penalties[:meta_review]
          penalties[:meta_review] = 0
        end
        @total_penalty = (penalties[:submission] + penalties[:review] + penalties[:meta_review])
        l_policy = LatePolicy.find(@assignment.late_policy_id)
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
      @all_penalties[participant.id] = {}
      @all_penalties[participant.id][:submission] = penalties[:submission]
      @all_penalties[participant.id][:review] = penalties[:review]
      @all_penalties[participant.id][:meta_review] = penalties[:meta_review]
      @all_penalties[participant.id][:total_penalty] = @total_penalty
    end
    unless @assignment.is_penalty_calculated
      @assignment.update_attribute(:is_penalty_calculated, true)
    end
  end

  def make_chart()
    @grades_bar_charts = {}
    if @pscore[:review]
      scores=[]
      if @assignment.varying_rubrics_by_round?
        for round in 1 .. @assignment.rounds_of_reviews
          responses = @pscore[:review][:assessments].reject{|response| response.round!=round}
          scores = scores.concat(get_scores_for_chart responses, 'review'+round.to_s)
          scores = scores-[-1.0]
        end
        @grades_bar_charts[:review] = bar_chart(scores)
      else
        scores = get_scores_for_chart @pscore[:review][:assessments], 'review'
        scores = scores-[-1.0]
        @grades_bar_charts[:review] = bar_chart(scores)
      end

    end

    if @pscore[:metareview]
     scores = get_scores_for_chart @pscore[:metareview][:assessments], 'metareview'
     scores = scores-[-1.0]
     @grades_bar_charts[:metareview] = bar_chart(scores)
    end

    if @pscore[:feedback]
      scores = get_scores_for_chart @pscore[:feedback][:assessments], 'feedback'
      scores = scores-[-1.0]
      @grades_bar_charts[:feedback] = bar_chart(scores)
    end

    if @pscore[:teammate]
      scores = get_scores_for_chart @pscore[:teammate][:assessments], 'teammate'
      scores = scores-[-1.0]
      @grades_bar_charts[:teammate] = bar_chart(scores) 
    end
  end

  def get_scores_for_chart(reviews, symbol)
    scores = []
    reviews.each do |review|
      scores << Answer.get_total_score(:response => [review], :questions => @questions[symbol.to_sym], :q_types => Array.new)
    end
    scores
  end

  def calculate_average_vector(scores)
    scores[:teams].reject!{|k,v| v[:scores][:avg].nil?}
    return scores[:teams].map{|k,v| v[:scores][:avg].to_i}
  end

  def bar_chart(scores, width=100, height=100, spacing=1)
    link = nil
    GoogleChart::BarChart.new("#{width}x#{height}", " ", :vertical, false) do |bc|
      data = scores
      bc.data "Line green", data, '990000'
      bc.axis :y, :range => [0, data.max] ,:positions => [data.min, data.max]
      bc.show_legend = false
      bc.stacked = false
      bc.width_spacing_options({:bar_width => (width-30)/(data.size+1),:bar_spacing => 1, :group_spacing => spacing })
      bc.data_encoding = :extended
      link = (bc.to_url)  
    end
    link
  end

  def reliability_chart(score,type)
    GoogleChart::BarChart.new("25x20", " ", :horizontal, false) do |bc|

      if score == 'good'
        data = [1,1,1]
        color = '00ff00'
      elsif score == 'medium'
        data = [1,1]
        color = 'FFCC00'
      else
        data = [1]
        color = '990000'
      end

      bc.data "Reliability Symbol", data, color
      bc.show_legend = false
      bc.stacked = false
      bc.width_spacing_options({:bar_width => 5,:bar_spacing => 10, :group_spacing => 1})
      bc.data_encoding = :extended
      @grades_bar_charts[type.to_sym] = (bc.to_url)
    end
  end

  #authorizations: reader,submitter, reviewer
  def are_needed_authorizations_present?
    @participant = Participant.find(params[:id])
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'reader' or authorization == 'reviewer'
      return false
    else
      return true
    end
  end

  def mean(array)
    array.inject(0) { |sum, x| sum += x } / array.size.to_f
  end

  def mean_and_standard_deviation(array)
    m = mean(array)
    variance = array.inject(0) { |variance, x| variance += (x - m) ** 2 }
    return m, Math.sqrt(variance/(array.size-1))
  end

end
