class CreateTeammateReviews < ActiveRecord::Migration
  def self.up
    create_table :teammate_reviews do |t|
      # Note: Table name pluralized by convention.
      t.column "reviewer_id", :integer
      t.column "reviewee_id", :integer
      t.column "assignment_id", :integer
      #t.column "team_id", :integer
      t.column "additional_comment", :text
    end
    begin
      add_column :assignments, :teammate_review_questionnaire_id, :integer
    rescue
    end
    
    add_index "teammate_reviews", ["reviewer_id"], :name => "fk_reviewer_id_users"

    execute "alter table teammate_reviews 
               add constraint fk_reviewer_id_users
               foreign key (reviewer_id) references users(id)"
               
    add_index "teammate_reviews", ["reviewee_id"], :name => "fk_reviewee_id_users"

    execute "alter table teammate_reviews 
               add constraint fk_reviewee_id_users
               foreign key (reviewee_id) references users(id)"
  
    
     add_index "teammate_reviews", ["assignment_id"], :name => "fk_teammate_reviews_assignments"
     
     execute "alter table teammate_reviews
              add constraint fk_teammate_reviews_assignments
              foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :teammate_reviews
  end
end
