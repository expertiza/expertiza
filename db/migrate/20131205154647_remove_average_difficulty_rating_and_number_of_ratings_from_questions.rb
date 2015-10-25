class RemoveAverageDifficultyRatingAndNumberOfRatingsFromQuestions < ActiveRecord::Migration
  def self.up
    remove_column :questions, :average_difficulty_rating
    remove_column :questions, :number_of_ratings
  end

  def self.down
    add_column :questions, :number_of_ratings, :integer
    add_column :questions, :average_difficulty_rating, :float
  end
end
