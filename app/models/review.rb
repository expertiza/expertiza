class Review < ActiveRecord::Base
  has_many :review_feedbacks
  has_many :review_scores
  belongs_to :mapping, :class_name => 'ReviewMapping', :foreign_key => 'mapping_id'
  
  def display_as_html(prefix = nil, count = nil)
    if prefix
       code = "<B>Reviewer:</B> "+self.mapping.reviewer.fullname+'&nbsp;&nbsp;&nbsp;<a href="#" name= "review_'+prefix+"_"+self.id.to_s+'Link" onClick="toggleElement('+"'review_"+prefix+"_"+self.id.to_s+"','review'"+');return false;">hide review</a><BR/>'
    else
       code = '<B>Review '+count.to_s+'</B> &nbsp;&nbsp;&nbsp;<a href="#" name= "review_'+self.id.to_s+'Link" onClick="toggleElement('+"'review_"+self.id.to_s+"','review'"+');return false;">show review</a><BR/>'           
    end
    code = code + "<B>Last reviewed:</B> "
    if self.updated_at.nil?
      code = code + "Not available"
    else
      code = code + self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end
    if prefix
      code = code + '<div id="review_'+prefix+"_"+self.id.to_s+'" style="">'
    else
      code = code + '<div id="review_'+self.id.to_s+'" style="display:none">'
    end
    code = code + '<BR/><BR/>'
    
    questionnaire = Questionnaire.find(self.mapping.assignment.review_questionnaire_id)
    questions = questionnaire.questions
    scores = Array.new
    questions.each{
       | question |
       score = Score.find_by_question_id_and_instance_id(question.id, self.id)
       if score
         scores << score
       end
    } 
    
    count = 0
    scores.each{
      | reviewScore |
      count = count + 1
      code = code + "<B>Question "+count.to_s+": </B><I>"+Question.find_by_id(reviewScore.question_id).txt+"</I><BR/><BR/>"
      code = code + '&nbsp;&nbsp;&nbsp;(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments.gsub("<","&lt;").gsub(">","&gt;")+"<BR/><BR/>"
    }     
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ''
    end
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
    type_id = QuestionnaireType.find_by_name("Review").id
    scores = Score.find_all_by_instance_id_and_questionnaire_type_id(self.id,type_id)
    scores.each {|score| score.destroy}
    fmaps = FeedbackMapping.find_all_by_reviewed_object_id(self.id)
    fmaps.each{
      |fmap|
       feedback = ReviewFeedback.find_by_mapping_id(fmap.id)
       feedback.delete
       fmap.destroy
    }        
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
   mapping = ReviewMapping.find(self.mapping_id)   
   if !mapping.assignment.team_assignment
    for participant in mapping.get_participants
     if participant.user.email_on_review
        Mailer.deliver_message(
            {:recipients => participant.user.email,
             :subject => "A new review is available for #{participant.user.name}",
             :body => {
              :obj_name => participant.user.name,
              :type => "review",
              :location => get_review_number(mapping).to_s,
              :review_scores => Score.find(:all, :conditions=>["instance_id=? and questionnaire_type_id=?",self.id, QuestionnaireType.find_by_name("Review").id]),
              :user => ApplicationHelper::get_user_first_name(participant.user),
              :partial_name => "update"
              }
            }
        )
     end  
    end
   end
 end
 
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)
   mapping = ReviewMapping.find(self.review_mapping_id)
   instructor = User.find(mapping.assignment.instructor_id)  
   puts "*** in sending method ***"
   Mailer.deliver_message(
     {:recipients => instructor.email,
      :subject => "Expertiza Notification: A review score is outside the acceptable range",
      :body => {        
        :first_name => ApplicationHelper::get_user_first_name(instructor),
        :reviewer_name => mapping.reviewer.fullname,
        :type => "review",
        :reviewee_name => mapping.reviewee.fullname,
        :limit => limit,
        :new_pct => new_pct,
        :avg_pct => avg_pct,
        :types => "reviews",
        :performer => "reviewer",
        :assignment => mapping.assignment,    
        :partial_name => 'limit_notify'
      }
     }
   )
          
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
