class RenamePeerReviews < ActiveRecord::Migration
  def self.up      
       execute "RENAME TABLE `pg_development`.`peer_reviews`  TO `pg_development`.`teammate_reviews`;"
       execute "RENAME TABLE `pg_development`.`peer_review_scores`  TO `pg_development`.`teammate_review_scores`;"
    
    
       execute "alter table pg_development.teammate_reviews drop foreign key fk_peer_reviews_assignments"
       execute "alter table pg_development.teammate_reviews drop index fk_peer_reviews_assignments"
       
       add_index "teammate_reviews", ["assignment_id"], :name => "fk_teammate_reviews_assignments"
     
       execute "alter table teammate_reviews
                add constraint fk_teammate_reviews_assignments
                foreign key (assignment_id) references assignments(id)"     
              
       execute "alter table pg_development.teammate_review_scores drop foreign key fk_peer_review_score_peer_reviews"
       execute "alter table pg_development.teammate_review_scores drop index fk_peer_review_score_peer_reviews"

       execute "alter table pg_development.teammate_review_scores drop foreign key fk_peer_review_score_questions"
       execute "alter table pg_development.teammate_review_scores drop index fk_peer_review_score_questions"
       
       execute " ALTER TABLE `teammate_review_scores` CHANGE `peer_review_id` `teammate_review_id` INT( 11 ) NULL DEFAULT NULL"
       
       add_index "teammate_review_scores", ["teammate_review_id"], :name => "fk_teamate_review_score_teammate_reviews"

       execute "alter table teammate_review_scores 
                add constraint fk_teamate_review_score_teammate_reviews
                foreign key (teammate_review_id) references teammate_reviews(id)"
               
       add_index "teammate_review_scores", ["question_id"], :name => "fk_teammate_review_score_questions"
 
       execute "alter table teammate_review_scores 
                add constraint fk_teammate_review_score_questions
                foreign key (question_id) references questions(id)"                                
  end

  def self.down
  end
end
