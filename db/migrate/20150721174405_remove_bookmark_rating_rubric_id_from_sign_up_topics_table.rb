class RemoveBookmarkRatingRubricIdFromSignUpTopicsTable < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :sign_up_topics, :bookmark_rating_rubric_id
  end
end
