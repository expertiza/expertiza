class AddNumMetareviewsAllowedToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :num_metareviews_allowed, :integer, default: 3
  end
end
