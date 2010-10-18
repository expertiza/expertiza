class CreateTeammateReviewMappings < ActiveRecord::Migration
  def self.up
    create_table :teammate_review_mappings do |t|
      t.column :reviewer_id, :integer, :null => false
      t.column :reviewee_id, :integer, :null => false
      t.column :reviewed_object_id, :integer, :null => false
    end
    
    add_column :teammate_reviews, :mapping_id, :integer, :null => false
    records = ActiveRecord::Base.connection.select_all("select * from `teammate_reviews`")
      
    records.each{
       | review |
       reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(review["reviewer_id"], review["assignment_id"])
       if reviewer.nil?
         reviewer = AssignmentParticipant.create(:user_id => review["reviewer_id"], :parent_id => review["assignment_id"])
         reviewer.set_handle()
       end
       reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(review["reviewer_id"], review["assignment_id"])
       if reviewee.nil?
         reviewee = AssignmentParticipant.create(:user_id => review["reviewer_id"], :parent_id => review["assignment_id"])
         reviewee.set_handle()
       end
       if reviewer != nil and reviewee != nil
          map = TeammateReviewMapping.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => review["assignment_id"])
       else
          puts "REVIEWER: #{review["reviewer_id"]}"
          puts "REVIEWEE: #{review["reviewe3_id"]}"
          puts review.id
       end
       execute "update `teammate_reviews` set `mapping_id` = #{map.id} where `id` = #{review["id"]}"           
    }
                
    execute "ALTER TABLE `teammate_reviews` 
             DROP FOREIGN KEY `fk_reviewer_id_users`"             
    execute "ALTER TABLE `teammate_reviews` 
             DROP INDEX `fk_reviewer_id_users`"
 
    remove_column :teammate_reviews, :reviewer_id
    
    execute "ALTER TABLE `teammate_reviews` 
             DROP FOREIGN KEY `fk_reviewee_id_users`"             
    execute "ALTER TABLE `teammate_reviews` 
             DROP INDEX `fk_reviewee_id_users`"

  
    remove_column :teammate_reviews, :reviewee_id
    
    execute "ALTER TABLE `teammate_reviews` 
             DROP FOREIGN KEY `fk_teammate_reviews_assignments`"             
    execute "ALTER TABLE `teammate_reviews` 
             DROP INDEX `fk_teammate_reviews_assignments`"

      
    remove_column :teammate_reviews, :assignment_id
    
    add_column :teammate_reviews, :created_at, :datetime, :null => true
    add_column :teammate_reviews, :updated_at, :datetime, :null => true
  end

  def self.down
    add_column :teammate_reviews, :reviewer_id, :integer, :null => false
    add_column :teammate_reviews, :reviewee_id, :integer, :null => false
    add_column :teammate_reviews, :assignment_id, :integer, :null => false
    
    TeammateReview.find(:all).each{
      | review |
      map = TeammateReviewMapping.find(review.mapping_id)
      review.reviewer_id = map.reviewer_id
      review.reviewee_id = map.reviewee_id
      review.assignment_id = map.reviewed_object_id
      review.save
    }
    
    remove_column :teammate_reviews, :mapping_id
    drop_table :teammate_review_mappings
  end
end
