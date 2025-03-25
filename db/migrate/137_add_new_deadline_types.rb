class AddNewDeadlineTypes < ActiveRecord::Migration[4.2]
  def change
    DeadlineType.create(name: 'bidding_for_topics')
    DeadlineType.create(name: 'bidding_for_reviews')
  end
end