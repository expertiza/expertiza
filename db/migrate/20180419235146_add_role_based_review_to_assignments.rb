class AddRoleBasedReviewToAssignments < ActiveRecord::Migration
  def change
  	add_column :assignments, :role_based_review, :boolean
  end
end
