class AddTeammateReviewDeadlineType < ActiveRecord::Migration
  def self.up
    DeadlineType.create :name => "teammate_review"
  end

  def self.down
    DeadlineType.find_by_name("teammate_review").destroy
  end
end
