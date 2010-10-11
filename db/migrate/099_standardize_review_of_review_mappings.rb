class StandardizeReviewOfReviewMappings < ActiveRecord::Migration  
  def self.up

    begin
       execute "ALTER TABLE `review_of_review_mappings` 
                DROP FOREIGN KEY `fk_review_of_review_mapping_review_mappings`"
    rescue
    end
  
    begin
      execute "ALTER TABLE `review_of_review_mappings` 
               DROP INDEX `fk_review_of_review_mapping_review_mappings`"
    rescue
    end
                         
    
    add_column :review_of_review_mappings, :reviewee_id, :integer, :null => false
    rename_column :review_of_review_mappings, :review_mapping_id, :reviewed_object_id

    
    records = ActiveRecord::Base.connection.select_all("select * from `review_of_review_mappings`")

    records.each{
      | mapping |
      begin
        update_mapping(mapping)
      rescue
        delete(mapping,$!)
      end
    }
    
    remove_column :review_of_review_mappings, :review_reviewer_id           
    change_column :review_of_review_mappings, :reviewer_id, :integer, :null => false      
    change_column :review_of_review_mappings, :reviewed_object_id, :integer, :null => false
    
    execute "ALTER TABLE `review_of_review_mappings` 
             ADD CONSTRAINT `fk_review_of_review_mappings_participant_reviewers`
             FOREIGN KEY (reviewer_id) references participants(id)"
             
    execute "ALTER TABLE `review_of_review_mappings` 
             ADD CONSTRAINT `fk_review_of_review_mappings_participant_reviewees`
             FOREIGN KEY (reviewee_id) references participants(id)"             
             
    execute "ALTER TABLE `review_of_review_mappings` 
             ADD CONSTRAINT `fk_review_of_review_mappings_review_mappings`
             FOREIGN KEY (reviewed_object_id) references review_mappings(id)"           
  end
  
  def self.update_mapping(mapping)
      today = Time.now             
      oldest_allowed_time = Time.local(today.year - 1,today.month,today.day,0,0,0)     

      review = ActiveRecord::Base.connection.select_one("select * from `review_of_reviews` where mapping_id = #{mapping["id"]}")
      review_mapping = ActiveRecord::Base.connection.select_one("select * from `review_mappings` where id = #{mapping["reviewed_object_id"]}")

      assignment = Assignment.find(review_mapping.assignment_id)
      if assignment.nil?
         raise "DELETE ReviewOfReviewMapping #{mapping["id"]}: No assignment found for #{mapping["id"]}: #{mapping["reviewed_object_id"]}"
      end
       
      if review.nil? and (assignment.created_at.nil? or assignment.created_at < oldest_allowed_time)
        raise "DELETE ReviewOfReviewMapping #{mapping["id"]}: The mapping is at least a year old and has no review associated with it."
      end
      
      if mapping["review_reviewer_id"] != nil
        reviewer = make_participant(mapping["review_reviewer_id"], assignment.id)        
      else
        reviewer = make_participant(mapping["reviewer_id"], assignment.id)      
      end      

      if reviewer.nil?        
        raise "DELETE ReviewOfReviewMapping #{mapping["id"]}: The reviewer does not exist as a participant: assignment_id: #{assignment.id}, user_id #{mapping["reviewer_id"]} or user_id: #{mapping["review_reviewer_id"]}"
      end            
           
      reviewee = make_participant(review_mapping["reviewer_id"], assignment.id)      
      
      if reviewee.nil?
        raise "DELETE ReviewOfReviewMapping #{mapping["id"]}: The reviewee does not exist as a participant: assignment_id: #{assignment.id}, user_id #{review_mapping["reviewer_id"]}"
      end
      
      mapping.update_attribute('reviewer_id',reviewer.id) 
      mapping.update_attribute('reviewee_id',reviewee.id)    
  end
  
  # create a participant based on a user and assignment
  def self.make_participant(user_id, assignment_id)
    participant = nil
    if user_id.to_i > 0
      user = User.find(user_id)
      if user
        participant = AssignmentParticipant.find_by_user_id_and_parent_id(user_id,assignment_id)
        
        if participant.nil?       
          participant = AssignmentParticipant.create(:user_id => user_id, :parent_id => assignment_id)
          participant.set_handle()      
        end
      end     
    end
    return participant
  end  
  
  def self.delete(mapping, reason)
    puts reason
    begin
      execute "delete from `review_of_review_mappings` where id = #{mapping["id"]}"
      mapping.delete(true)
    rescue
      puts $!
    end
  end  

  def self.down
  end
end
