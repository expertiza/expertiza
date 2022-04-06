class RenamePeerReviews < ActiveRecord::Migration[4.2]
  def self.up
    begin
      rename_table :peer_reviews, :teammate_reviews
    rescue StandardError
    end

    begin
      rename_table :peer_review_scores, :teammate_review_scores
    rescue StandardError
    end

    begin
      execute 'alter table teammate_reviews drop foreign key fk_peer_reviews_assignments'
    rescue StandardError
    end

    begin
      execute 'alter table teammate_reviews drop index fk_peer_reviews_assignments'
    rescue StandardError
    end

    begin
      execute 'ALTER TABLE `teammate_reviews`
            ADD CONSTRAINT fk_teammate_reviews_assignments
            FOREIGN KEY (assignment_id) REFERENCES assignments(id)'
    rescue StandardError
    end

    begin
      execute 'alter table teammate_review_scores drop foreign key fk_peer_review_score_peer_reviews'
    rescue StandardError
    end

    begin
      execute 'alter table teammate_review_scores drop index fk_peer_review_score_peer_reviews'
    rescue StandardError
    end

    begin
      execute 'alter table teammate_review_scores drop foreign key fk_peer_review_score_questions'
    rescue StandardError
    end

    begin
      execute 'alter table teammate_review_scores drop index fk_peer_review_score_questions'
    rescue StandardError
    end

    begin
      change_column :teammate_review_scores, :peer_review_id, :teammate_review_id, :integer, null: true
    rescue StandardError
    end

    begin
     execute "alter table teammate_review_scores
              add constraint fk_teamate_review_score_teammate_reviews
              foreign key (teammate_review_id) references teammate_reviews(id)"
    rescue StandardError
   end

    begin
      execute "alter table teammate_review_scores
               add constraint fk_teammate_review_score_questions
               foreign key (question_id) references questions(id)"
    rescue StandardError
    end
  end

  def self.down; end
end
