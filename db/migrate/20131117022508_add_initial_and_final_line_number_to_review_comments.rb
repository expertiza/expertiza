class AddInitialAndFinalLineNumberToReviewComments < ActiveRecord::Migration
  def self.up
    add_column :review_comments, :initial_line_number, :integer
    add_column :review_comments, :last_line_number, :integer
  end

  def self.down
    remove_column :review_comments, :initial_line_number
    remove_column :review_comments, :last_line_number
  end
end

