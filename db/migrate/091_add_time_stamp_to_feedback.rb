class AddTimeStampToFeedback < ActiveRecord::Migration
  def self.up
    add_column :review_feedbacks, :created_at, :datetime, :null => true
    add_column :review_feedbacks, :updated_at, :datetime, :null => true
  end

  def self.down
  end
end
