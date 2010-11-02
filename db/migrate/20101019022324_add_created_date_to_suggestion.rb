class AddCreatedDateToSuggestion < ActiveRecord::Migration
# OSS project_Team1 (rsjohns3) CSC517 Fall 2010
# This migration adds a createdDate column to the Suggestions table
# to allow student suggestions to be sorted by createdDate
#  
  def self.up
    add_column :suggestions, :createdDate, :datetime
  end

  def self.down
    remove_column :suggestions, :createdDate
  end
end
