class AddRatingOfDifficultyToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :average_difficulty_rating, :float, :default => 0
    add_column :questions, :number_of_ratings, :integer, :default => 0
  end

  def self.down
    remove_column :questions, :number_of_ratings
    remove_column :questions, :average_difficulty_rating
  end
end
