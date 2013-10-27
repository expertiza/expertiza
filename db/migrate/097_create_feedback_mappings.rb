class CreateFeedbackMappings < ActiveRecord::Migration
  def self.up    
    create_table :feedback_mappings do |t|
        t.column :reviewer_id, :integer, :null => false
        t.column :reviewee_id, :integer, :null => false
        t.column :reviewed_object_id, :integer, :null => false
    end
    

    execute "ALTER TABLE `feedback_mappings` 
             ADD CONSTRAINT `fk_feedback_mappings_review`
             FOREIGN KEY (reviewed_object_id) references reviews(id)"     
             
    execute "ALTER TABLE `feedback_mappings` 
             ADD CONSTRAINT `fk_feedback_mappings_reviewer_participant`
             FOREIGN KEY (reviewer_id) references participants(id)"
             
    execute "ALTER TABLE `feedback_mappings` 
             ADD CONSTRAINT `fk_feedback_mappings_reviewee_participant`
             FOREIGN KEY (reviewee_id) references participants(id)"    
    
    add_column :review_feedbacks, :mapping_id, :integer, :null => false     
    records = ActiveRecord::Base.connection.select_all("select * from `review_feedbacks`")
    
    records.each{
       | feedback | 
       review = ActiveRecord::Base.connection.select_one("select * from `reviews` where id = #{feedback["review_id"]}")
       reviewmap = ActiveRecord::Base.connection.select_one("select * from `review_mappings` where id = #{review["review_mapping_id"]}")
       
       if reviewmap != nil
         reviewer = get_reviewer(reviewmap, feedback)
         reviewee = AssignmentParticipant.find(:first, :conditions => ['user_id = ? and parent_id = ?',reviewmap["reviewer_id"], feedback["assignment_id"]])         
       end       
       if reviewer != nil and reviewee != nil 
         execute "INSERT INTO `feedback_mappings (`reviewer_id`, `reviewee_id`, `reviewed_object_id`) VALUES
            (#{reviewer.id}, #{reviewee.id}, #{review["id"]});" 
         map = ActiveRecord::Base.connection.select_one("select * from `feedback_mappings` where id = (select max(id) from `feedback_mappings`)")
         execute "update `review_feedbacks` set mapping_id = #{map.id} where id = #{feedback["id"]}"         
       else
         execute "delete from `review_feedbacks where id = #{feedback["id"]}"         
       end
    }
    
    
    execute "ALTER TABLE `review_feedbacks` 
             ADD CONSTRAINT `fk_review_feedback_mappings`
             FOREIGN KEY (mapping_id) references feedback_mappings(id)"    
    
    execute "ALTER TABLE `review_feedbacks` 
             DROP FOREIGN KEY `fk_review_feedback_assignments`"             
    execute "ALTER TABLE `review_feedbacks` 
             DROP INDEX `fk_review_feedback_assignments`"
 
    execute "ALTER TABLE `review_feedbacks` 
             DROP FOREIGN KEY `fk_review_feedback_reviews`"             
    execute "ALTER TABLE `review_feedbacks` 
             DROP INDEX `fk_review_feedback_reviews`"            
    begin
      remove_column :review_feedbacks, :assignment_id
    rescue
    end
   
    begin
      remove_column :review_feedbacks, :review_id
    rescue
    end
  
    begin
      remove_column :review_feedbacks, :user_id
    rescue
    end
  
    begin
      remove_column :review_feedbacks, :author_id
    rescue
    end
    
    begin
      remove_column :review_feedbacks, :team_id
    rescue 
    end                   
  end
  
  def self.get_reviewer(map, feedback)    
    reviewer = nil
    assignment = Assignment.find(map["assignment_id"])    
    if assignment.team_assignment 
       if feedback["user_id"].nil?
          if map["team_id"] != nil
             team = AssignmentTeam.find(map["team_id"])
             reviewer = team.get_participants.first
          end              
       else
          reviewer = AssignmentParticipant.find(:first, :conditions => ['user_id = ? and parent_id = ?',feedback["user_id"], feedback["assignment_id"]])  
       end                          
    else
       reviewer = AssignmentParticipant.find(:first, :conditions => ['user_id = ? and parent_id = ?',map["author_id"], feedback["assignment_id"]])
    end
    return reviewer
  end

  def self.down
    add_column :review_feedbacks, :review_id, :integer, :null => false
    add_column :review_feedbacks, :author_id, :integer, :null => false
    add_column :review_feedbacks, :team_id, :integer, :null => false
    add_column :review_feedbacks, :assignment_id, :integer, :null => false
    
    ReviewFeedback.find(:all).each{
      | feedback |
      map = FeedbackMapping.find(feedback.mapping_id)
      
      
      feedback.assignment_id = map.assignment.id
      feedback.review_id = map.reviewed_object_id
      feedback.author_id = map.reviewer.user_id
      if map.assignment.team_assignment
        feedback.team_id = map.reviewer.team.id
      end
      feedback.save      
    }
    
    remove_column :teammate_reviews, :mapping_id
    drop_table :teammate_review_mappings
  end
end
