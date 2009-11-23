class StandardizeReviewMappings < ActiveRecord::Migration
  def self.up
    begin
      execute "ALTER TABLE `review_mappings` 
               DROP FOREIGN KEY `fk_review_mapping_assignments`"
    rescue
    end
    
    begin
      execute "ALTER TABLE `review_mappings` 
               DROP INDEX `fk_review_mapping_assignments`"
    rescue
    end
     
    begin
      execute "ALTER TABLE `review_mappings`
               DROP FOREIGN KEY `fk_review_users_reviewer`"
    rescue               
    end
  
    begin
      execute "ALTER TABLE `review_mappings`
               DROP INDEX `fk_review_users_reviewer`"
    rescue               
    end
 
    begin
      execute "ALTER TABLE `review_mappings`
               DROP FOREIGN KEY `fk_review_users_author`"
    rescue               
    end
  
    begin
      execute "ALTER TABLE `review_mappings`
               DROP INDEX `fk_review_users_author`"
    rescue               
    end    
     
    begin
      execute "ALTER TABLE `review_mappings`
               DROP FOREIGN KEY `fk_review_teams`"
    rescue               
    end
  
    begin
      execute "ALTER TABLE `review_mappings`
               DROP INDEX `fk_review_teams`"
    rescue               
    end        
     
    rename_column :review_mappings, :reviewer_id, :old_reviewer_id
    add_column :review_mappings, :reviewer_id, :integer, :null => false
    add_column :review_mappings, :reviewee_id, :integer, :null => false
    rename_column :review_mappings, :assignment_id, :reviewed_object_id
    remove_column :review_mappings, :round
    add_column :review_mappings, :type, :string, :null => false
    
    ReviewMapping.find(:all).each{
       | mapping |
       assignment = Assignment.find(mapping.reviewed_object_id)
       if assignment.nil?
         delete(mapping,"No assignment found for "+mapping.id.to_s+": "+mapping.reviewed_object_id.to_s)               
       else
          if mapping.old_reviewer_id == 0
            delete(mapping, "No reviewer ID")            
          end
          
          reviewer = get_participant_reviewer(mapping)
          
          if assignment.team_assignment
            type = 'TeamReviewMapping'
            reviewee = get_team_reviewee(mapping)       
          else
            type = 'ParticipantReviewMapping'
            reviewee = get_participant_reviewee(mapping)
          end
       
          
         
          if reviewee.nil? or reviewer.nil?
            reason = "Removing: "+mapping.id.to_s+" for assignment "+mapping.reviewed_object_id.to_s
            if reviewee.nil?
              reason = reason + "\n   No reviewee: author("+mapping.author_id.to_s+") team("+mapping.team_id.to_s+")"
            end
            if reviewer.nil?
              reason = reason + "\n   No reviewer: "+mapping.old_reviewer_id.to_s
            end
            delete(mapping, reason)
          else
            mapping.update_attribute('reviewee_id', reviewee.id)
            mapping.update_attribute('reviewer_id', reviewer.id)
            mapping.update_attribute('type',type)
          end
       end
    }      
    
    remove_column :review_mappings, :author_id
    remove_column :review_mappings, :team_id
    remove_column :review_mappings, :old_reviewer_id
    
    execute "ALTER TABLE `review_mappings` 
             ADD CONSTRAINT `fk_review_mappings_participant_reviewers`
             FOREIGN KEY (reviewer_id) references participants(id)"
             
    execute "ALTER TABLE `review_mappings` 
             ADD CONSTRAINT `fk_review_mappings_assignments`
             FOREIGN KEY (reviewed_object_id) references assignments(id)"  
             

    execute "ALTER TABLE `reviews` 
             ADD CONSTRAINT `fk_review_review_mapping`
             FOREIGN KEY (mapping_id) references review_mappings(id)"             
    
  end
  
  def self.delete(mapping, reason)
    puts reason
    begin
      mapping.delete(true)
    rescue
      puts $!
    end
  end
  
  # return the participant acting as reviewer for this mapping
  def self.get_participant_reviewer(mapping)
    return make_participant(mapping.old_reviewer_id, mapping.reviewed_object_id)
  end
  
  # return the participant acting as reviewee for this mapping
  def self.get_participant_reviewee(mapping)
    return make_participant(mapping.author_id, mapping.reviewed_object_id)
  end
  
  # return the team acting as reviewee for this mapping
  def self.get_team_reviewee(mapping)
    if mapping.team_id != nil
       begin
        reviewee = AssignmentTeam.find(mapping.team_id)
       rescue
        puts "   "+$!
       end
    elsif mapping.author_id != nil
       participant = make_participant(mapping.author_id,mapping.reviewed_object_id)
       reviewee = participant.team
    else
       mapping.destroy
    end
    
    if reviewee.nil?
       reviewee = create_team(mapping)
    end    
    return reviewee
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

  # if a team does not already exist to act as a reviewee, create it based on the author id provided
  def self.create_team(mapping)
     # if the author is not available, no team can be made
     if mapping.author_id == 0 or mapping.author_id.nil?
       return nil
     end
     
     # create a participant for this user, all users have to be a participant in order to interact with an assignment
     user = User.find(mapping.author_id)     
     if AssignmentParticipant.find_by_user_id_and_parent_id(mapping.author_id, mapping.reviewed_object_id).nil?
        make_participant(mapping.author_id, mapping.reviewed_object_id)
     end
     
     # if the user was found, create a team based on the user
     if user != nil
         team = AssignmentTeam.create(:name => 'Team'+mapping.author_id.to_s, :parent_id => mapping.reviewed_object_id)
         TeamsUser.create(:team_id => team.id, :user_id => mapping.author_id)         
     end    
     return team
  end

  def self.down
  end
end
