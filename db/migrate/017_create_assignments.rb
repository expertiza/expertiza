class CreateAssignments < ActiveRecord::Migration
  def self.up
  create_table "assignments", :force => true do |t|
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "name", :string
    t.column "directory_path", :string
    t.column "submitter_count", :integer, :limit => 10, :default => 0, :null => false
    t.column "course_id", :integer, :default => 0, :null => false
    t.column "instructor_id", :integer, :default => 0, :null => false
    t.column "private", :boolean, :default => false, :null => false
    t.column "num_reviews", :integer, :default => 0, :null => false
    t.column "num_review_of_reviews", :integer, :default => 0, :null => false
    t.column "num_review_of_reviewers", :integer, :default => 0, :null => false
    t.column "review_strategy_id", :integer, :default => 0, :null => false
    t.column "mapping_strategy_id", :integer, :default => 0, :null => false
    t.column "review_questionnaire_id", :integer
    t.column "review_of_review_questionnaire_id", :integer
    t.column "review_weight", :float
    t.column "reviews_visible_to_all", :boolean
    t.column "team_assignment", :boolean
    t.column "wiki_type_id", :integer
    t.column "require_signup", :boolean
    t.column "num_reviewers", :integer, :limit => 10, :default => 0, :null => false
    t.column "spec_location", :text
  end

  add_index "assignments", ["review_questionnaire_id"], :name => "fk_assignments_review_questionnaires"

  execute "alter table assignments 
             add constraint fk_assignments_review_questionnaires
             foreign key (review_questionnaire_id) references questionnaires(id)"
             
  add_index "assignments", ["review_of_review_questionnaire_id"], :name => "fk_assignments_review_of_review_questionnaires"

  execute "alter table assignments 
             add constraint fk_assignments_review_of_review_questionnaires
             foreign key (review_of_review_questionnaire_id) references questionnaires(id)"
             
  add_index "assignments", ["wiki_type_id"], :name => "fk_assignments_wiki_types"

  execute "alter table assignments 
             add constraint fk_assignments_wiki_types
             foreign key (wiki_type_id) references wiki_types(id)"
             
    
  end

  def self.down
    drop_table "assignments"
  end
end
