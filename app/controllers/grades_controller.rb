class GradesController < ApplicationController
  helper :file
  helper :submitted_content

  #the view grading report provides the instructor with an overall view of all the grades for
  #an assignment. It lists all participants of an assignment and all the reviews they recieved.
  #It also gives a final score which is an average of all the reviews and greatest difference
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
  end

  def view_my_scores
    @participant = AssignmentParticipant.find(params[:id])
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
      mmaps = MetareviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(rmap.reviewer_id, rmap.id)
      if !mmaps.nil?
        for mmap in mmaps
          mmap.notification_accepted = true
          mmap.save
        end
      end
    end


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

    @scores = @participant.get_scores(@questions)
  end

  def instructor_review
    participant = AssignmentParticipant.find(params[:id])

    reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, participant.assignment.id)
    if reviewer.nil?
      reviewer = AssignmentParticipant.create(:user_id => session[:user].id, :parent_id => participant.assignment.id)
      reviewer.set_handle()
    end

    if participant.assignment.team_assignment
      reviewee = participant.team
      review_mapping = TeamReviewResponseMap.find_by_reviewee_id_and_reviewer_id(reviewee.id, reviewer.id)
    else
      reviewee = participant
      review_mapping = ParticipantReviewResponseMap.find_by_reviewee_id_and_reviewer_id(reviewee.id, reviewer.id)
    end

    if review_mapping.nil?
      if participant.assignment.team_assignment
        review_mapping = TeamReviewResponseMap.create(:reviewee_id => participant.team.id, :reviewer_id => reviewer.id, :reviewed_object_id => participant.assignment.id)
      else
        review_mapping = ParticipantReviewResponseMap.create(:reviewee_id => participant.id, :reviewer_id => reviewer.id, :reviewed_object_id => participant.assignment.id)
      end
    end
    review = Response.find_by_map_id(review_mapping.id)

    if review.nil?
      redirect_to :controller => 'response', :action => 'new', :id => review_mapping.id, :return => "instructor"
    else
      redirect_to :controller => 'response', :action => 'edit', :id => review.id, :return => "instructor"
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
      process_response("Review", "Reviewer", @participant.get_reviews, "ReviewQuestionnaire")
    elsif @submission == "review_of_review"
      @symbol = "metareview"
      process_response("Metareview", "Metareviewer", @participant.get_metareviews, "MetareviewQuestionnaire")
    elsif @submission == "review_feedback"
      @symbol = "feedback"
      process_response("Feedback", "Author", @participant.get_feedback, "AuthorFeedbackQuestionnaire")
    elsif @submission == "teammate_review"
      @symbol = "teammate"
      process_response("Teammate Review", "Reviewer", @participant.get_teammate_reviews, "TeammateReviewQuestionnaire")
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
    @questionnaire =  @assignment.questionnaires.find_by_type(questionnaire_type)
    @max_score, @weight = @assignment.get_max_score_possible(@questionnaire)
  end

  def redirect_when_disallowed
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    ## This following code was cloned from response_controller.
    
    if @participant.assignment.team_assignment
      team = @participant.team
      if(!team.nil?)
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
end