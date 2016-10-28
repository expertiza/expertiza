class RemoveBookmarkRatingRubricIdFromSignUpTopicsTable < ActiveRecord::Migration
  def self.up
   remove_column :sign_up_topics, :bookmark_rating_rubric_id
  end
end
