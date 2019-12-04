class AddingDefaultValueToSelfTeammateReview < ActiveRecord::Migration
  def change
	change_column :assignments, :is_self_teammate_review_enabled, :boolean, default: false 
  end
end
