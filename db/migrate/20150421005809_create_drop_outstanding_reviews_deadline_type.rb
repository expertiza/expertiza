class CreateDropOutstandingReviewsDeadlineType < ActiveRecord::Migration
  def self.up
    DeadlineType.create :name => "drop_outstanding_reviews"
  end

  def self.down
    DeadlineType.find_by_name("drop_outstanding_reviews").destroy
  end
end
