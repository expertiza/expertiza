class CreateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
  create_table "metareview_mappings", :force => true do |t|
    t.column "review_mapping_id", :integer
    t.column "review_reviewer_id", :integer
    t.column "review_id", :integer
    t.column "assignment_id", :integer, :limit => 10
  end

  add_index "metareview_mappings", ["review_id"], :name => "fk_metareview_mapping_reviews"

  #execute "alter table metareview_mappings
  #           add constraint fk_metareview_mapping_reviews
  #           foreign key (review_id) references reviews(id)"
  
  add_index "metareview_mappings", ["review_mapping_id"], :name => "fk_metareview_mapping_review_mappings"

  #execute "alter table metareview_mappings
  #           add constraint fk_metareview_mapping_review_mappings
  #           foreign key (review_mapping_id) references review_mappings(id)"
 
  #add_index "metareview_mappings", ["reviewer_id"], :name => "fk_metareview_users"

  #execute "alter table metareview_mappings
  #           add constraint fk_metareview_users
  #           foreign key (reviewer_id) references users(id)"  
             
  #add_index "metareview_mappings", ["assignment_id"], :name => "fk_metareview_assignments"

  #execute "alter table metareview_mappings
  #           add constraint fk_metareview_assignments
  #           foreign key (assignment_id) references assignments(id)"               
  end

  def self.down
    drop_table "metareview_mappings"
  end
end
