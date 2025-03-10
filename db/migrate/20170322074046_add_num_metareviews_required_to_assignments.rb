class AddNumMetareviewsRequiredToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :num_metareviews_required, :integer, default: 3
  end
end
