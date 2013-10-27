class CreateReviewMappings < ActiveRecord::Migration
  def self.up
  create_table "review_mappings", :force => true do |t|
    t.column "author_id", :integer
    t.column "team_id", :integer
    t.column "reviewer_id", :integer
    t.column "assignment_id", :integer
  end

  add_index "review_mappings", ["assignment_id"], :name => "fk_review_mapping_assignments"

  execute "alter table review_mappings
             add constraint fk_review_mapping_assignments
             foreign key (assignment_id) references assignments(id)"
             
  add_index "review_mappings", ["reviewer_id"], :name => "fk_review_users_reviewer"

  execute "alter table review_mappings
             add constraint fk_review_users_reviewer
             foreign key (reviewer_id) references users(id)"  

  add_index "review_mappings", ["author_id"], :name => "fk_review_users_author"

  execute "alter table review_mappings
             add constraint fk_review_users_author
             foreign key (author_id) references users(id)"  

  add_index "review_mappings", ["team_id"], :name => "fk_review_teams"

  execute "alter table review_mappings
             add constraint fk_review_teams
             foreign key (team_id) references teams(id)"               
  end

  def self.down
    drop_table "review_mappings"
  end
end
