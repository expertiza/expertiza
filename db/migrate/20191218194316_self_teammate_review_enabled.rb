class SelfTeammateReviewEnabled < ActiveRecord::Migration
  def change
    add_column :assignments, :is_self_teammate_review_enabled, :boolean, :default => false
  end
end
