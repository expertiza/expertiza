module ReviewHelper
  def review_view_helper(review_id,current_folder_name,fname)
    @review = Review.find(params[review_id])
    @mapping_id = review_id
    @review_scores = Score.find(:all, :conditions=>["instance_id=? and questionnaire_type_id=?",@review.id, QuestionnaireType.find_by_name("Review").id])
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
    @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @assgt.id])
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_questionnaire_id]) 
    @questionnaire = Questionnaire.find(@assgt.review_questionnaire_id)
    
    if @assgt.team_assignment 
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score 
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if current_folder_name
      @current_folder.name = FileHelper::sanitize_folder(current_folder_name)
    end
    
    @files = Array.new
    @files = @author.get_submitted_files()
    
    if fname
      view_submitted_file(@current_folder,@author)
    end 
    return @files,@assgt,@author_name,@team_member,@rs,@mapping_id,@review_scores
  end
  
  # Compute the scores previously awarded to the recipient
  # ajbudlon, nov 18, 2008
  def self.get_total_scores(item_list,curr_item)
    total = 0
    count = 0
    item_list.each {
      | item | 
      if review.id != curr_item.id
        count += 1
        total += item.get_total_score                
      end
    } 
    return total,count
  end 
  
  # determine if the instructor should be notified
  # ajbudlon, nov 18, 2008
  def self.notify_instructor(assignment,curr_item,questionnaire)
      
      max_possible_score,weights = assignment.get_max_score_possible(questionnaire,questionnaire.questions)
      new_score = curr_item.get_total_score.to_f*weights    
      existing_score = (total.to_f/count).to_f*weights 
      notification = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id = ? and questionnaire_id = ?',assignment.instructor_id, assignment.id, questionnaire.id])
      if notification == nil
        notification = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',assignment.instructor_id])
      end
      allowed_difference = max_possible_score.to_f * notification.limit / 100      
      if new_score < (existing_score - allowed_difference) or new_score > (existing_score + allowed_difference)
        new_pct = new_score.to_f/max_possible_score
        avg_pct = existing_score.to_f/max_possible_score
        curr_item.notify_on_difference(new_pct,avg_pct,notification.limit)
      end    
  end  
end
