class ChangeSignuptopicIdToTopicIdInReviewBids < ActiveRecord::Migration
  def change
    rename_column :review_bids, :signuptopic_id, :topic_id
  end
end
