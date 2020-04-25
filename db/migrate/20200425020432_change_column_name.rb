class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :review_bids, :topic_id, :signuptopic_id
  end
end
