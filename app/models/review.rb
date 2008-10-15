class Review < ActiveRecord::Base
  has_many :review_feedbacks
  has_many :review_scores
  belongs_to :review_mapping
  
  def display_as_html(prefix) 
    code = "<B>Reviewer:</B> "+self.review_mapping.reviewer.fullname+'&nbsp;&nbsp;&nbsp;<a href="#" name= "review_'+prefix+"_"+self.id.to_s+'Link" onClick="toggleElement('+"'review_"+prefix+"_"+self.id.to_s+"','review'"+');return false;">hide review</a>'
    code = code + '<div id="review_'+prefix+"_"+self.id.to_s+'" style="">'   
    code = code + '<BR/><BR/>'
    scores = Score.find_by_sql("select * from scores where instance_id = "+self.id.to_s+" and questionnaire_type_id= "+ QuestionnaireType.find_by_name("Review").id)
    scores.each{
      | reviewScore |      
      code = code + "<I>"+reviewScore.question.txt+"</I><BR/><BR/>"
      code = code + '(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+reviewScore.question.questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments+"<BR/><BR/>"
    }          
    comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')    
    code = code + "<B>Additional Comment:</B><BR/>"+comment+""
    code = code + "</div>"
    return code
  end 
    
  # Computes the total score awarded for a review
  def get_total_score
    scores = Score.find(:all,:conditions=>["instance_id=? and questionnaire_type_id=?",self.id, QuestionnaireType.find_by_name("Review").id])
    total_score = 0
    scores.each{
      |item|
      total_score += item.score
    }   
    return total_score
  end
  
    def delete
      mappings = ReviewOfReviewMapping.find(:all, :conditions => ['review_id = ?',self.id])
      mappings.each {|mapping| mapping.delete}
      self.destroy
    end
  
    def self.review_view_helper(review_id,fname,control_folder)
    @review = Review.find(review_id)
    @mapping_id = review_id
    @review_scores = Score.find(:all, :conditions=>["instance_id=? and questionnaire_type_id=?",@review.id, QuestionnaireType.find_by_name("Review").id])
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
    @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @assgt.id])
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_questionnaire_id]) 
    @questionnaire = Questionnaire.find(@assgt.review_questionnaire_id)
    @control_folder = control_folder
    
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
    
    @files = Array.new
    @files = @author.get_submitted_files()
    
    if fname
      view_submitted_file(@current_folder,@author)
    end 
    return @files,@assgt,@author_name,@team_member,@rs,@mapping_id,@review_scores,@questionnaire,@max,@min
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

  # Generate emails for authors when a new review of their work
  # is made
  #ajbudlon, sept 07, 2007   
  def email
   mapping = ReviewMapping.find_by_id(self.review_mapping_id)   
   assignment = Assignment.find(mapping.assignment_id)
   if !assignment.team_assignment
   for author_id in mapping.get_author_ids
    if User.find_by_id(author_id).email_on_review
        user = User.find_by_id(author_id)
        Mailer.deliver_message(
            {:recipients => user.email,
             :subject => "An new submission is available for #{user.name}",
             :body => {
              :obj_name => user.name,
              :type => "review",
              :location => get_review_number(mapping).to_s,
              :review_scores => Score.find(:all, :conditions=>["instance_id=? and questionnaire_type_id=?",self.id, QuestionnaireType.find_by_name("Review").id]),
              :user => ApplicationHelper::get_user_first_name(user),
              :partial_name => "update"
              }
            }
        )
    end  
  end
  end
  end
  
  # Get all review mappings for this assignment & author
  # required to give reviewer location of new submission content
  # link can not be provided as it might give user ability to access data not
  # available to them.  
  #ajbudlon, sept 07, 2007       
  def get_review_number(mapping)
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
