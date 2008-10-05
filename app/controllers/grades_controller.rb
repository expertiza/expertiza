class GradesController < ApplicationController
  helper :file
  
  #the view grading report provides the instructor with an overall view of all the grades for
  #an assignment. It lists all participants of an assignment and all the reviews they recieved.
  #It also gives a final score which is an average of all the reviews and greatest difference
  #in the scores of all the reviews.  
  def view    
    @assignment = Assignment.find(params[:id])
    @participants = @assignment.get_participants
    if @assignment.team_assignment
      @teams = @assignment.get_teams
    end
  end  
  
  def open
    send_file(params['fname'],:disposition => 'inline')
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
      { :recipients => email_form[:recipients],
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
  
  # ther grading conflict email form provides the instructor a way of emailing
  # the reviewers of a submission if he feels one of the reviews was unfair or inaccurate.  
  def conflict_notification
    @instructor = session[:user]
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = Assignment.find(@participant.parent_id)  
    
    @reviews = Array.new    
    @reviewers_email_hash = Hash.new 
    
    if params[:submission] == '1'      
      process_review()   
    elsif params[:submission] == '2'
      process_metareview()
    elsif params[:submission] == '3'
      process_author_feedback()           
    elsif params[:submission] == '4'
      process_teammate_review()
    end       
  
    @subject = " Your "+@collabel.downcase+" score for " + @assignment.name + " conflicts with another "+@rowlabel.downcase+"'s score."
    @body = get_body_text(params[:submission])
    @submission = params[:submission]
  end
  
  def edit    
    @participant = AssignmentParticipant.find(params[:id])        
  end
  
  def update
    @participant = AssignmentParticipant.find(params[:id])
    if sprintf("%.2f",@participant.compute_total_score*100) != params[:participant][:grade]
      @participant.grade = params[:participant][:grade]
      @participant.save
    end
    
    redirect_to :action => 'edit', :id => params[:id]
  end
  
private  
  def process_review
      @collabel = "Review"
      @rowlabel = "Reviewer"
      if @assignment.team_assignment       
         @author = AssignmentTeam.find_by_sql("select distinct teams.* from teams, teams_users where teams.id = teams_users.team_id and teams.type = 'AssignmentTeam' and teams.parent_id = "+@assignment.id.to_s+" and teams_users.user_id = "+@participant.user_id.to_s).first      
         query = "assignment_id = ? and team_id = ?"
      else
         @author = @participant.user
         query = "assignment_id = ? and author_id = ?"
      end   
      mappings = ReviewMapping.find(:all, :conditions => [query,@assignment.id,@author.id])    
   
      mappings.each{
        | mapping |
        review = Review.find_by_review_mapping_id(mapping.id)
        if review
          @reviews << review
          @reviewers_email_hash[mapping.reviewer.fullname.to_s+" <"+mapping.reviewer.email.to_s+">"] = mapping.reviewer.email.to_s        
        end
      }    
      @reviews = @reviews.sort {|a,b| a.review_mapping.reviewer.fullname <=> b.review_mapping.reviewer.fullname}    
  end

  def process_author_feedback
      @collabel = "Feedback"
      @rowlabel = "Author"
      @author = @participant.user
      @reviews = @participant.get_feedbacks
      @reviews.each{
        |review|
        @reviewers_email_hash[review.reviewer.fullname.to_s+" <"+review.reviewer.email.to_s+">"] = review.reviewer.email.to_s
      }
        
      @reviews = @reviews.sort {|a,b| a.reviewer.fullname <=> b.reviewer.fullname}
  end

  def process_metareview
      @collabel = "Metareview"
      @rowlabel = "Metareviewer"
      @author = @participant.user
     
      mappings = ReviewOfReviewMapping.find_by_sql("select * from review_of_review_mappings where review_mapping_id in (select id from review_mappings where assignment_id = "+@assignment.id.to_s+" and reviewer_id = "+@author.id.to_s+")") 
      mappings.each {
        | mapping |
        review = ReviewOfReview.find_by_review_of_review_mapping_id(mapping.id)
        if review
           @reviews << review
           @reviewers_email_hash[mapping.review_reviewer.fullname.to_s+" <"+mapping.review_reviewer.email.to_s+">"] = mapping.review_reviewer.email.to_s
        end    
      }
      @reviews = @reviews.sort {|a,b| a.review_of_review_mapping.review_reviewer.fullname <=> b.review_of_review_mapping.review_reviewer.fullname}    
  end
  
  def process_teammate_review
      @collabel = "Teammate Review"
      @rowlabel = "Reviewer"
      @author = User.find(@participant.user_id)
      
      reviews = TeammateReview.find(:all, :conditions => ['reviewee_id =? and assignment_id =?',@author.id, @assignment.id])    
   
      reviews.each{
        | review |
        if review
          @reviews << review
          @reviewers_email_hash[review.reviewer.fullname.to_s+" <"+review.reviewer.email.to_s+">"] = review.reviewer.email.to_s        
        end
      }    
      @reviews = @reviews.sort {|a,b| a.reviewer.fullname <=> b.reviewer.fullname}    
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
