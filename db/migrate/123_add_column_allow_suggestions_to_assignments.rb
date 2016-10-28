class AddColumnAllowSuggestionsToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :allow_suggestions, :boolean
  end

  def self.down
    remove_column :assignments, :allow_suggestions
  end
end
