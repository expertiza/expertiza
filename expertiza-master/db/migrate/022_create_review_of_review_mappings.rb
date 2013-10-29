class CreateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
  create_table "review_of_review_mappings", :force => true do |t|
    t.column "review_mapping_id", :integer
    t.column "review_reviewer_id", :integer
    t.column "review_id", :integer
    t.column "assignment_id", :integer, :limit => 10
  end

  add_index "review_of_review_mappings", ["review_id"], :name => "fk_review_of_review_mapping_reviews"

  #execute "alter table review_of_review_mappings
  #           add constraint fk_review_of_review_mapping_reviews
  #           foreign key (review_id) references reviews(id)"
  
  add_index "review_of_review_mappings", ["review_mapping_id"], :name => "fk_review_of_review_mapping_review_mappings"

  #execute "alter table review_of_review_mappings
  #           add constraint fk_review_of_review_mapping_review_mappings
  #           foreign key (review_mapping_id) references review_mappings(id)"
 
  #add_index "review_of_review_mappings", ["reviewer_id"], :name => "fk_review_of_review_users"

  #execute "alter table review_of_review_mappings
  #           add constraint fk_review_of_review_users
  #           foreign key (reviewer_id) references users(id)"  
             
  #add_index "review_of_review_mappings", ["assignment_id"], :name => "fk_review_of_review_assignments"

  #execute "alter table review_of_review_mappings
  #           add constraint fk_review_of_review_assignments
  #           foreign key (assignment_id) references assignments(id)"               
  end

  def self.down
    drop_table "review_of_review_mappings"
  end
end
