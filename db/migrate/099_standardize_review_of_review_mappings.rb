class StandardizeReviewOfReviewMappings < ActiveRecord::Migration  
  def self.up

    execute "ALTER TABLE `review_of_review_mappings` 
             DROP FOREIGN KEY `fk_review_of_review_mapping_review_mappings`"             
    execute "ALTER TABLE `review_of_review_mappings` 
             DROP INDEX `fk_review_of_review_mapping_review_mappings`"    
    
    add_column :review_of_review_mappings, :reviewee_id, :integer, :null => false
    rename_column :review_of_review_mappings, :review_mapping_id, :reviewed_object_id
    
    
    ReviewOfReviewMapping.find(:all).each{
      | mapping |
      review_mapping = ReviewMapping.find(mapping.reviewed_object_id)
      if mapping.review_reviewer_id != nil
        reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(mapping.review_reviewer_id, review_mapping.assignment_id)        
      else
        reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(mapping.reviewer_id, review_mapping.assignment_id)      
      end
     
      reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(review_mapping.reviewer, review_mapping.assignment_id)
      
      if reviewer != nil and reviewee != nil
        mapping.reviewer_id = reviewer.id 
        mapping.reviewee_id = reviewee.id
        mapping.save
      elsif reviewer.nil?
        rors = ReviewOfReview.find_all_by_mapping_id(mapping.id)
        rors.each{
            |ror|
             ror.delete
        }        
        mapping.destroy
      else
        rors = ReviewOfReview.find_all_by_mapping_id(mapping.id)
        rors.each{
            |ror|
             ror.delete
        }        
        mapping.destroy        
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

  def self.down
  end
end
