class AddBookmarkRatingRubricIdToSignupTopic < ActiveRecord::Migration
  def self.up
    add_column :sign_up_topics, :bookmark_rating_rubric_id, :integer, :default => nil
  end

  def self.down
    remove_column :sign_up_topics, :bookmark_rating_rubric_id
  end
end

