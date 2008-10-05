class AssignmentParticipant < Participant  
  require 'wiki_helper'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id'
  
  def get_course_string
    # if no course is associated with this assignment, or if there is a course with an empty title, or a course with a title that has no printing characters ...
    if self.assignment.course == nil or self.assignment.course.name == nil or self.assignment.course.name.strip == ""
      return "<center>&#8212;</center>"
    end
    return self.assignment.course.name
  end
  
  def get_feedbacks
    review_mapping_query = "select id from review_mappings where assignment_id = "+self.assignment.id.to_s+" and reviewer_id = "+self.user.id.to_s    
    review_query = "select id from reviews where review_mapping_id in ("+review_mapping_query+")"
    
    feedbacks = ReviewFeedback.find_by_sql("select * from review_feedbacks where review_id in ("+review_query+")")
    return feedbacks.sort {|a,b| a.reviewer.name <=> b.reviewer.name}    
  end
  
  def get_reviews
    if self.assignment.team_assignment
      author_id = self.team.id
      query = "team_id = ? and assignment_id = ?"
    else
      author_id = self.user_id
      query = "author_id = ? and assignment_id = ?"
    end
    
    reviews = Array.new
    
    ReviewMapping.find(:all, :conditions => [query,author_id,self.parent_id]).each{
      |mapping|
      review = Review.find_by_review_mapping_id(mapping.id)     
      if review
        reviews << review
      end
    }
    return reviews.sort {|a,b| a.review_mapping.reviewer.fullname <=> b.review_mapping.reviewer.fullname }
  end
  
  def get_metareviews    
    mreviews = Array.new  
    
    rm_query = "select id from review_mappings where assignment_id = "+self.parent_id.to_s+" and reviewer_id = "+self.user_id.to_s
    query = "select * from review_of_review_mappings where review_mapping_id in("+rm_query+")"    
    ReviewOfReviewMapping.find_by_sql(query).each{    
      | mrmapping |
      mreview = ReviewOfReview.find_by_review_of_review_mapping_id(mrmapping.id)
      if mreview        
        mreviews << mreview
      end
    }
    return mreviews.sort {|a,b| a.review_of_review_mapping.reviewer.fullname <=> b.review_of_review_mapping.reviewer.fullname }      
  end
  
  def get_teammate_reviews    
    previews = Array.new  
    pr_query = "select * from teammate_reviews where assignment_id = "+self.parent_id.to_s+" and reviewee_id = "+self.user_id.to_s
    TeammateReview.find_by_sql(pr_query).each{    
      | pr |
      if pr        
        previews << pr
      end
    }
    return previews.sort {|a,b| a.reviewer.fullname <=> b.reviewer.fullname }      
  end  
  
  def has_submissions    
    if (self.submitted_hyperlink and self.submitted_hyperlink.strip.length > 0)
      hplink = true
    else
      hplink = false
    end
    return ((get_submitted_files.length > 0) or 
            (get_wiki_submissions.length > 0) or 
            (hplink)) 
  end
 
  def get_submitted_files()
    files = Array.new
    if(self.directory_num)      
      files = get_files(self.get_path)
    end
    return files
  end  
  
  def get_files(directory)
      files_list = Dir[directory + "/*"]
      files = Array.new
      for file in files_list
        if not File.directory?(Dir.pwd + "/" + file) then
          files << file
        else
          dir_files = get_files(file)
          dir_files.each{|f| files << f}
        end
      end
      return files
  end
  
  def get_wiki_submissions     
    currenttime = Time.now.month.to_s + "/" + Time.now.day.to_s + "/" + Time.now.year.to_s
 
    if Assignment.find(self.parent_id).team_assignment and Assignment.find(self.parent_id).wiki_type.name == "MediaWiki"

       submissions = Array.new
       self.team.get_team_users().each {
         | user |
         submissions << WikiType.review_mediawiki(Assignment.find(self.parent_id).directory_path, currenttime, user.name)
       }
       return submissions
    elsif Assignment.find(self.parent_id).wiki_type.name == "MediaWiki"
       return WikiType.review_mediawiki(Assignment.find(self.parent_id).directory_path, currenttime, self.name)       
    elsif Assignment.find(self.parent_id).wiki_type.name == "DocuWiki"
       return WikiType.review_docuwiki(Assignment.find(self.parent_id).directory_path, currenttime, self.name)             
    else
       return Array.new
    end
  end    
    
  def team
       query = "select distinct teams.* from teams, teams_users"
       query = query + " where teams.type = 'AssignmentTeam'"
       query = query + " and teams.parent_id = "+self.parent_id.to_s
       query = query + " and teams.id = teams_users.team_id"
       query = query + " and teams_users.user_id = "+self.user_id.to_s       
       Team.find_by_sql(query).first    
  end
    
  #computes this participant's current teammate review scores:
  # avg_review_score
  # difference
  def compute_teammate_review_scores #(participant_id)
    #participant = Participants.find_by_id(participant_id)
    if Assignment.find(self.parent_id).team_assignment
      teammate_reviews = TeammateReview.find_by_sql("select * from teammate_reviews where reviewee_id = #{self.user_id} and assignment_id = #{self.parent_id}")
      if teammate_reviews.length > 0
        avg_review_score, max_score,min_score = AssignmentParticipant.compute_scores(teammate_reviews)     
        max_assignment_score = Assignment.find(self.parent_id).get_max_teammate_review_score
        return avg_review_score/max_assignment_score,max_score/max_assignment_score,min_score/max_assignment_score
      else
        return nil,nil
    end
   end
  end
  
  #computes this participants current metareview score
  #metareview = review_of_review
  def compute_metareview_scores    
    review_mapping_query = "select id from review_mappings where assignment_id = #{self.parent_id} and reviewer_id = #{self.user_id}"
    metareview_mapping_query = "select id from review_of_review_mappings where review_mapping_id in ("+review_mapping_query+")"
    metareview_query = "select * from review_of_reviews where review_of_review_mapping_id in ("+metareview_mapping_query+")"
    metareviews = ReviewOfReview.find_by_sql(metareview_query)
    if metareviews.length > 0
      avg_metareview_score, max_score,min_score = AssignmentParticipant.compute_scores(metareviews)
      max_assignment_score = Assignment.find(self.parent_id).get_max_metareview_score
      return avg_metareview_score/max_assignment_score, max_score/max_assignment_score, min_score/max_assignment_score
    else
      return nil,nil
    end
  end
 
  #computes this participants current author feedback score
  def compute_author_feedback_scores   
    review_mapping_query = "select id from review_mappings where assignment_id = "+self.assignment.id.to_s+" and reviewer_id = "+self.user.id.to_s    
    review_query = "select id from reviews where review_mapping_id in ("+review_mapping_query+")"
    
    feedbacks = ReviewFeedback.find_by_sql("select * from review_feedbacks where review_id in ("+review_query+")")
    if feedbacks.length > 0
      avg_feedback_score, max_score,min_score = AssignmentParticipant.compute_scores(feedbacks)
      max_assignment_score = self.assignment.get_max_feedback_score
      return avg_feedback_score/max_assignment_score, max_score/max_assignment_score, min_score/max_assignment_score
    else
      return nil,nil
    end
  end  
  
  def compute_review_scores
    if Assignment.find(self.parent_id).team_assignment
      return self.team.compute_review_scores
    else
      reviews = Review.find_by_sql("select * from reviews where review_mapping_id in (select id from review_mappings where author_id = #{self.user_id} and assignment_id = #{self.parent_id})")
      if reviews.length > 0
        avg_review_score, max_score,min_score = AssignmentParticipant.compute_scores(reviews)     
        max_assignment_score = Assignment.find(self.parent_id).get_max_review_score
        return avg_review_score/max_assignment_score,max_score/max_assignment_score,min_score/max_assignment_score
      else
        return nil,nil
    end
   end    
  end
  
  def compute_total_score   
    review_score,max,min = self.compute_review_scores
     
    if review_score
      r_score = review_score * (self.assignment.review_weight / 100).to_f
    end    
    metareview_score,max,min = self.compute_metareview_scores
    if metareview_score
      m_score = metareview_score * ((100 - self.assignment.review_weight) / 100).to_f
    end
    
    if r_score and m_score
      #if self.assignment.team_assignment and teammate_review_score
      # return (r_score + m_score)*teammate_review_score
      #else
       return r_score + m_score
      #end
    elsif r_score
      #if self.assignment.team_assignment and teammate_review_score
      #  return (review_score)*teammate_review_score
      #else
        return review_score
      #end        
    else
      return 0
    end
  end  
  
  def self.compute_scores(list)
    max_score = 0
    min_score = 999999999
    total_score = 0
    list.each {
      | item | 
       curr_score = item.get_total_score       
       if curr_score > max_score
         max_score = curr_score
       end
       if curr_score < min_score
         min_score = curr_score
       end        
       total_score += curr_score       
    }   
    average_score = total_score.to_f / list.length.to_f    
    return average_score, max_score, min_score
  end
  

  
  # provide import functionality for Assignment Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,session,id)
    if row.length != 4
       raise ArgumentError, "Not enough items" 
    end
    user = User.find_by_name(row[0])        
    if (user == nil)
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end                  
    if Assignment.find(id) == nil
       raise ImportError, "The assignment with id \""+id.to_s+"\" was not found."
    end
    if (find(:all, {:conditions => ['user_id=? AND parent_id=?', user.id, id]}).size == 0)
       create(:user_id => user.id, :parent_id => id)
    end   
  end   
  
  def get_path
     Assignment.find(self.parent_id).get_path + "/"+ self.directory_num.to_s
  end
  
  def set_student_directory_num
    if self.directory_num.nil? or self.directory_num < 0           
      maxnum = AssignmentParticipant.find(:first, :conditions=>['parent_id = ?',self.parent_id], :order => 'directory_num desc').directory_num
      if maxnum
        self.directory_num = maxnum + 1
      else
        self.directory_num = 0
      end
      self.save
      
      if Assignment.find(self.parent_id).team_assignment
         query = "select teams_users.* from teams_users, teams"
         query = query + " where teams.type = 'AssignmentTeam'"
         query = query + " and teams.parent_id = '"+self.parent_id.to_s+"'"
         query = query + " and teams.id = teams_users.team_id"
         TeamsUser.find_by_sql(query).each{
          | member |
          participant = AssignmentParticipant.find_by_user_id_and_parent_id(member.user_id, self.parent_id)
          if participant.directory_num == nil or participant.directory_num < 0
            participant.directory_num = self.directory_num
            participant.save
          end
         }
      end
    end
  end   
end
