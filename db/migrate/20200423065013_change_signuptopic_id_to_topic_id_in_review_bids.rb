class ChangeSignuptopicIdToTopicIdInReviewBids < ActiveRecord::Migration
  def change
    rename_column :review_bids, :sign_up_topic_id, :topic_id
  end
end
