class GradesController < ApplicationController
  
  #the view grading report provides the instructor with an overall view of all the grades for
  #an assignment. It lists all participants of an assignment and all the reviews they recieved.
  #It also gives a final score which is an average of all the reviews and greatest difference
  #in the scores of all the reviews.  
  def view    
    @max_num_of_reviews = 0;
    @assignment = Assignment.find(params[:id])
        
    if @assignment.team_assignment      
      author_type = 'team_id'
    else
      author_type = 'author_id'
    end
    mappings = ReviewMapping.find_by_sql("select distinct #{author_type} from review_mappings where assignment_id = #{@assignment.id} order by #{author_type}")
        
    @scores_by_author = Array.new 
 
    mappings.each {
      | mappings |
      
      entry = Hash.new
      
      if @assignment.team_assignment
        entry[:author] = Team.find(mappings.team_id)
      else
        entry[:author] = User.find(mappings.author_id)
      end
      
      entry[:review_scores] = Array.new
      
      entry[:total_author_score] = 0
      entry[:num_reviews] = 0
      
      reviews = Review.find_by_sql("select * from reviews where review_mapping_id in (select id from review_mappings where assignment_id  = #{@assignment.id} and #{author_type} = #{entry[:author].id})")
      max_score = 0
      min_score = 100
      
      reviews.each{
        |review|
        total_review_score = 0      
        if !review.nil?  
          entry[:num_reviews] += 1
          score_entry = Hash.new
          scores = ReviewScore.find(:all, :conditions => ['review_id = ?',review.id]) 
          scores.each { | item | total_review_score += item.score}
          score_entry[:review] = review
          score_entry[:total_review_score] = total_review_score
          if total_review_score > max_score
            max_score = total_review_score
          end
          if total_review_score < min_score
            min_score = total_review_score
          end
          entry[:review_scores] << score_entry
        end    
        entry[:total_author_score] += total_review_score        
      } 
      
      if entry[:num_reviews] > @max_num_of_reviews
        @max_num_of_reviews = entry[:num_reviews]
      end      
      if entry[:num_reviews] > 0
        entry[:average_author_score] = entry[:total_author_score].to_f / entry[:num_reviews].to_f
        entry[:max_score] = max_score
        entry[:min_score] = min_score        
        entry[:diff] = max_score - min_score
      else
        entry[:average_author_score] = 0
        entry[:diff] = 0
      end
      @scores_by_author << entry
      
    @sum_of_max = 0
    @sum_of_max_ror = 0
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).questions
      @sum_of_max += Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).max_question_score
    end
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_of_review_questionnaire_id).questions
      @sum_of_max_ror += Questionnaire.find(Assignment.find(@assignment.id).review_of_review_questionnaire_id).max_question_score
    end  
    }          
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
    @instructor = session[:user];
    @sum_of_max = 0
    @student = Participant.find(params[:id])
    @assignment = @student.assignment
    @reviewers_email_hash = {}
    @reviewers = Array.new
    @subject = " Your review score for " + @assignment.name + " conflicts with another reviewers."
    
    @body = get_body_text
      
    @users_grades = Array.new
    all_grades = ReviewScore.find_by_sql("select review_id, sum(score) as total_score from review_scores group by review_id order by total_score") 
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).questions
      @sum_of_max += Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).max_question_score
    end
    for grade in all_grades
      if grade.review.review_mapping.author_id.to_s == @student.user.id.to_s
        @users_grades << grade
        reviewer = grade.review.review_mapping.reviewer
        @reviewers << grade.review.review_mapping.reviewer
        @reviewers_email_hash[reviewer.fullname.to_s+" <"+reviewer.email.to_s+">"] = reviewer.email.to_s
      end
    end
    @reviewers = @reviewers.sort {|a,b| a.fullname <=> b.fullname}
  end
  
  #the final grade report is a page that summarizes all the information an instructor
  #might need to assign a grade for an assignment. Currently it provides all review scores left
  #for an assignment (as well as the comments) and the author feedback (with comments).
  #Support for review of reviews, submission versions and teams still needs to be added.
  def edit
    
  end
  
  #this saves the the final grade for a participant of an assignment, as well as saving
  #comments for the student and the instructor. It is called from the final_grade_reports page
  def save_final_grade
    form = params[:participant]
    student = Participant.find(form[:student])
    student.grade = form[:grade]
    student.comments_to_student = form[:student_comments]
    student.private_instructor_comments = form[:non_student_comments]
     
    if student.save
      flash[:note] = 'Final grade was successfully submitted.'
      redirect_to :action => 'final_grade_report', :id => form[:student]
    else
      flash[:notice] = 'An error occured trying to submit the final grade. Please ensure you provided a grade greater than or equal to zero.'
      redirect_to :action => 'final_grade_report', :id => form[:student]
    end
  end
  
private
  def get_body_text
    "Hi ##[recipient_name], 
    
You submitted a score of ##[recipients_grade] for assignment ##[assignment_name] that 
varied greatly from another reviewer's score for the same submission.  
The Expertiza system has brought this to my attention.

"
  end  
end
