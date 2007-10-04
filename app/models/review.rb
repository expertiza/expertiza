class Review < ActiveRecord::Base
  has_many :review_feedbacks
  has_many :review_scores
  
    def self.review_view_helper(review_id,fname,control_folder)
    @review = Review.find(review_id)
    @mapping_id = review_id
    @review_scores = @review.review_scores
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
    @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @assgt.id])
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", @assgt.review_rubric_id]) 
    @rubric = Rubric.find(@assgt.review_rubric_id)
    @control_folder = control_folder
    
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
    
    @files = Array.new
    @files = get_submitted_file_list(@direc, @author, @files)
    
    if fname
      view_submitted_file(@current_folder,@author)
    end 
    return @files,@assgt,@author_name,@team_member,@rs,@mapping_id,@review_scores,@rubric,@max,@min
  end
   def self.get_submitted_file_list(direc,author,files)
    if(author.directory_num)
      direc = RAILS_ROOT + "/pg_data/" + author.assignment.directory_path + "/" + author.directory_num.to_s
      temp_files = Dir[direc + "/*"]
      for file in temp_files
        if not File.directory?(Dir.pwd + "/" + file) then
          files << file
        end
      end
    end
    return files
  end
    #follows a link
  #needs to be moved to a separate helper function
  def self.view_submitted_file(current_folder,author)
    folder_name = StudentAssignmentHelper::sanitize_folder(current_folder.name)
    file_name = StudentAssignmentHelper::sanitize_filename(params['fname'])
    file_split = file_name.split('.')
    if file_split.length > 1 and (file_split[1] == 'htm' or file_split[1] == 'html')
      send_file(RAILS_ROOT + "/pg_data/" + author.assignment.directory_path + "/" + @author.directory_num.to_s + folder_name + "/" + file_name, :type => Mime::HTML.to_s, :disposition => 'inline') 
    else
      send_file(RAILS_ROOT + "/pg_data/" + author.assignment.directory_path + "/" + @author.directory_num.to_s + folder_name + "/" + file_name) 
    end
  end

  # Generate emails for authors when a new review of their work
  # is made
  #ajbudlon, sept 07, 2007   
  def email
   mapping = ReviewMapping.find_by_id(self.review_mapping_id)   
   for author_id in mapping.get_author_ids
    if User.find_by_id(author_id).email_on_review
        user = User.find_by_id(author_id)
        Pgmailer.deliver_message(
            {:recipient => user.email,
             :subject => "An new submission is available for #{self.name}",
             :body => {
              :obj_name => self.name,
              :type => "review",
              :location => getReviewNumber(mapping).to_s,
              :review_scores => self.review_scores,
              :user => ApplicationHelper::get_user_first_name(user),
              :partial_name => "update"
              }
            }
        )
    end  
   end
  end
  
  # Get all review mappings for this assignment & author
  # required to give reviewer location of new submission content
  # link can not be provided as it might give user ability to access data not
  # available to them.  
  #ajbudlon, sept 07, 2007       
  def getReviewNumber(mapping)
    reviewer_mappings = ReviewMapping.find_by_sql(
      "select * from review_mappings where assignment_id = " +self.id.to_s +
      " and author_id = " + mapping.author_id.to_s
    )
    review_num = 1
    for rm in reviewer_mappings
      if rm.reviewer_id != mapping.reviewer_id
        review_num += 1
      else
        break
      end
    end  
    return review_num
  end
end
