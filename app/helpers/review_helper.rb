module ReviewHelper
  def review_view_helper(review_id,current_folder_name,fname)
    @review = Review.find(params[review_id])
    @mapping_id = review_id
    @review_scores = @review.review_scores
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
    @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @assgt.id])
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", @assgt.review_rubric_id]) 
    @rubric = Rubric.find(@assgt.review_rubric_id)
    
    if @assgt.team_assignment 
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score 
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if current_folder_name
      @current_folder.name = StudentAssignmentHelper::sanitize_folder(current_folder_name)
    end
    
    @files = Array.new
    @files = get_submitted_file_list(@direc, @author, @files)
    
    if fname
      view_submitted_file(@current_folder,@author)
    end 
    return @files,@assgt,@author_name,@team_member,@rs,@mapping_id,@review_scores
  end
end
