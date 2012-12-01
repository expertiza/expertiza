class Add < ActiveRecord::Migration
  def self.up
    add_column :review_comments, :inital_line_number, :integer
    add_column :review_comments, :last_line_number, :integer
  end

  def self.down
    remove :review_comments, :inital_line_number
    remove :review_comments, :last_line_number
  end
end
