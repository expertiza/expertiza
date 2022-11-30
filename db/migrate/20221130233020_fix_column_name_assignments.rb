class FixColumnNameAssignments < ActiveRecord::Migration[5.1]
  def change
    rename_column :assignments, :is_intelligent, :bid_for_topics
  end
end
