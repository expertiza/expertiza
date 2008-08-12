class CreatePeerReviews < ActiveRecord::Migration
  def self.up
    create_table :peer_reviews do |t|
      # Note: Table name pluralized by convention.
      t.column "reviewer_id", :integer
      t.column "reviewee_id", :integer
      t.column "assignment_id", :integer
      #t.column "team_id", :integer
      t.column "additional_comment", :text
    end
    begin
      add_column :assignments, :peer_review_questionnaire_id, :integer
    rescue
    end
    
    add_index "peer_reviews", ["reviewer_id"], :name => "fk_reviewer_id_users"

    execute "alter table peer_reviews 
               add constraint fk_reviewer_id_users
               foreign key (reviewer_id) references users(id)"
               
    add_index "peer_reviews", ["reviewee_id"], :name => "fk_reviewee_id_users"

    execute "alter table peer_reviews 
               add constraint fk_reviewee_id_users
               foreign key (reviewee_id) references users(id)"
  
    
     add_index "peer_reviews", ["assignment_id"], :name => "fk_peer_reviews_assignments"
     
     execute "alter table peer_reviews
              add constraint fk_peer_reviews_assignments
              foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :peer_reviews
  end
end
