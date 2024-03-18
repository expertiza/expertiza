class AddColumnAllowSuggestionsToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :allow_suggestions, :boolean
  end

  def self.down
    remove_column :assignments, :allow_suggestions
  end
end
