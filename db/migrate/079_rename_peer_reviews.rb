class RenamePeerReviews < ActiveRecord::Migration
  def self.up
    begin
       execute "RENAME TABLE `pg_development`.`peer_reviews`  TO `pg_development`.`teammate_reviews`;"
     rescue
       end
     begin
       execute "RENAME TABLE `pg_development`.`peer_review_scores`  TO `pg_development`.`teammate_review_scores`;"
    rescue
       end
    begin
       execute "alter table pg_development.teammate_reviews drop foreign key fk_peer_reviews_assignments"
       rescue
     end
     begin
       execute "alter table pg_development.teammate_reviews drop index fk_peer_reviews_assignments"
       rescue
     end
     begin
       add_index "teammate_reviews", ["assignment_id"], :name => "fk_teammate_reviews_assignments"
     rescue
   end
   begin
       execute "alter table teammate_reviews
                add constraint fk_teammate_reviews_assignments
                foreign key (assignment_id) references assignments(id)"
                rescue
       end
       begin
              
       execute "alter table pg_development.teammate_review_scores drop foreign key fk_peer_review_score_peer_reviews"
       rescue
     end
     begin
       execute "alter table pg_development.teammate_review_scores drop index fk_peer_review_score_peer_reviews"
rescue
end
      begin
       execute "alter table pg_development.teammate_review_scores drop foreign key fk_peer_review_score_questions"
       rescue
     end
     begin
       execute "alter table pg_development.teammate_review_scores drop index fk_peer_review_score_questions"
       rescue
       end
       begin
       execute " ALTER TABLE `teammate_review_scores` CHANGE `peer_review_id` `teammate_review_id` INT( 11 ) NULL DEFAULT NULL"
       rescue
       end
       begin
       add_index "teammate_review_scores", ["teammate_review_id"], :name => "fk_teamate_review_score_teammate_reviews"
       rescue
       end
    begin
       execute "alter table teammate_review_scores 
                add constraint fk_teamate_review_score_teammate_reviews
                foreign key (teammate_review_id) references teammate_reviews(id)"
     rescue
   end
   begin
       add_index "teammate_review_scores", ["question_id"], :name => "fk_teammate_review_score_questions"
  rescue
end
    begin
       execute "alter table teammate_review_scores 
                add constraint fk_teammate_review_score_questions
                foreign key (question_id) references questions(id)"
      rescue
    end        
  end

  def self.down
  end
end
