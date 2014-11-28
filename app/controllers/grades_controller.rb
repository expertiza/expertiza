class GradesController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper


  def action_allowed?
    case params[:action]
    when 'view_my_scores'
      current_role_name.eql? 'Student'
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name
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
    questionnaires.each do |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    end
    @scores = @assignment.get_scores(@questions)
    calculate_all_penalties(@assignment.id)
  end

  def view_my_scores
    @participant = AssignmentParticipant.find(params[:id])
    @average_score_results = ScoreCache.get_class_scores(@participant.id)

    @statistics = @average_score_results

    @average_reviews = ScoreCache.get_reviews_average(@participant.id)
    @average_metareviews = ScoreCache.get_metareviews_average(@participant.id)

    @my_reviews = ScoreCache.my_reviews(@participant.id)
    @my_metareviews = ScoreCache.my_metareviews(@participant.id)

    return if redirect_when_disallowed
    @assignment = @participant.assignment
    @questions = {}
    questionnaires = @assignment.questionnaires
    questionnaires.each do |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    end

    ## When user clicks on the notification, it should go away
    #deleting all review notifications
    rmaps = ParticipantReviewResponseMap.where(reviewee_id: @participant.id, reviewed_object_id: @participant.assignment.id)
    rmaps.find_each do |rmap|
      rmap.update_attribute :notification_accepted, true
    end

    #deleting all metareview notifications
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
    @assignment_id = @participant.parent_id
    @score_cache = Array.new

    assignment_participants = AssignmentParticipant.where(:parent_id => @assignment_id).to_a

    @scores = [0,0,0,0,0,0,0,0,0,0]

    for ap in assignment_participants
      sc = ScoreCache.find_by_reviewee_id(ap.id)
      if !sc.is_a?(NilClass)
        @score_cache <<  sc.score
      end
    end


    #  for x ion score_cache
    @score_cache.each{|x|
      index=(x/10).to_i
      if(index>=10)
        index=9
      end
      @scores[index] =  @scores[index] + 1
    }




    @chart1 = GoogleChart::BarChart.new("600x300", "Vertical Bar Graph",:vertical, false) do |bc|
      bc.data "FirstResult Bar", @scores, '9A0000'
      bc.axis :x
      bc.axis :y, :labels => (0..@scores.max).to_a
      bc.show_legend = false
      bc.data_encoding = :extended
    end


    #data_array_1 = [1, 4, 3, 5, 9]
    #data_array_2 = [4, 2, 10, 4, 7]

    #@chart2= Gchart.bar(:data => [1,2,4,67,100,41,234], :max_value => 300)

    #@chart3 = bar_chart = Gchart.new(
    # :type => 'bar'
    # :size =>
    # )


   # @chart1.axis([GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT])

    #dataset = GoogleChartDataset.new :data => @scores, :color => '9A0000'
    #data = GoogleChartData.new :datasets => [dataset]
    #axis = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]
    #@chart1 = GoogleBarChart.new :width => 500, :height => 200
    #@chart1.data = data
    #@chart1.axis = axis


=begin

    ###################### Second Graph ####################

    max_score = 0
    @review_distribution =[0,0,0,0,0,0,0,0,0,0]
    ### For every responsemapping for this assgt, find the reviewer_id and reviewee_id #####
    @reviews_not_done = 0

    if(@assignment.team_assignment)
      objtype = "TeamReviewResponseMap"
    else
      objtype = "ParticipantReviewResponseMap"
    end

    response_maps =  ResponseMap.where("reviewed_object_id = ? and type = ?", @assignment.id, objtype)
    review_report = @assignment.compute_reviews_hash
    for response_map in response_maps
      score_for_this_review = review_report[response_map.reviewer_id][response_map.reviewee_id]
      if(score_for_this_review != 0)
        @review_distribution[(score_for_this_review/10-1).to_i] = @review_distribution[(score_for_this_review/10-1).to_i] + 1
        if (@review_distribution[(score_for_this_review/10-1).to_i] > max_score)
          max_score = @review_distribution[(score_for_this_review/10-1).to_i]
        end
      else
        @reviews_not_done +=1
      end
    end

    #dataset2 = GoogleChartDataset.new :data => @review_distribution, :color => '9A0000'
    #data2 = GoogleChartData.new :datasets => [dataset2]
    #axis2 = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]

    #@chart2 = GoogleBarChart.new :width => 500, :height => 200
    #@chart2.data = data2
    #@chart2.axis = axis2

    @chart2 = GoogleChart::BarChart.new("600x300", "Vertical Bar Graph",:vertical, false) do |bc|
      bc.data "FirstResult Bar", @review_distribution, '9A0000'
      bc.axis :x
      bc.axis :y, :labels => (0..@scores.max).to_a
      bc.show_legend = false
      bc.data_encoding = :extended
    end
=end

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
      else
        review_mapping = ParticipantReviewResponseMap.create(:reviewee_id => participant.id, :reviewer_id => reviewer.id, :reviewed_object_id => participant.assignment.id)
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
    recipient = User.where(["email = ?", email_form[:recipients]]).first

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


      @questions = {}
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
      if(!team.nil?)
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

=begin
  def distribution(pid)
    @participant = AssignmentParticipant.find(pid)
    @assignment_id = @participant.parent_id
    @assignment = Assignment.find(@assignment_id)

    @scores = [0,0,0,0,0,0,0,0,0,0]
    if(@assignment.team_assignment)
      teams = Team.find_all_by_parent_id(params[:id])
      objtype = "TeamReviewResponseMap"
    else
      teams = Participant.find_all_by_parent_id(params[:id])
      objtype = "ParticipantReviewResponseMap"
    end

    teams.each do |team|
      score_cache = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?",team.id,  objtype])
      t_score = 0
      if score_cache!= nil
        t_score = score_cache.score
      end
      if (t_score != 0)
        @scores[(t_score/10).to_i] =  @scores[(t_score/10).to_i] + 1
      end
    end


    dataset = GoogleChartDataset.new :data => @scores, :color => '9A0000'
    data = GoogleChartData.new :datasets => [dataset]
    axis = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]
    @chart1 = GoogleBarChart.new :width => 500, :height => 200
    @chart1.data = data
    @chart1.axis = axis


    ###################### Second Graph ####################

    max_score = 0
    @review_distribution =[0,0,0,0,0,0,0,0,0,0]
    ### For every responsemapping for this assgt, find the reviewer_id and reviewee_id #####
    @reviews_not_done = 0
    response_maps =  ResponseMap.find(:all, :conditions =>["reviewed_object_id = ? and type = ?", @assignment.id, objtype])
    review_report = @assignment.compute_reviews_hash
    for response_map in response_maps
      score_for_this_review = review_report[response_map.reviewer_id][response_map.reviewee_id]
      if(score_for_this_review != 0)
        @review_distribution[(score_for_this_review/10-1).to_i] = @review_distribution[(score_for_this_review/10-1).to_i] + 1
        if (@review_distribution[(score_for_this_review/10-1).to_i] > max_score)
          max_score = @review_distribution[(score_for_this_review/10-1).to_i]
        end
      else
        @reviews_not_done +=1
      end
    end

    dataset2 = GoogleChartDataset.new :data => @review_distribution, :color => '9A0000'
    data2 = GoogleChartData.new :datasets => [dataset2]
    axis2 = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]

    @chart2 = GoogleBarChart.new :width => 500, :height => 200
    @chart2.data = data2
    @chart2.axis = axis2

  end
=end

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
end