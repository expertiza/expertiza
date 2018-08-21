class AddBadgeIdToFileInstructions < ActiveRecord::Migration
  def change
    add_column :file_instructions, :badge_id, :integer
  end
end
