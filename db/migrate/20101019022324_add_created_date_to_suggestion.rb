class AddCreatedDateToSuggestion < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :createdDate, :datetime
  end

  def self.down
    remove_column :suggestions, :createdDate
  end
end
