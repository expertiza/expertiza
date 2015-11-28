class AddSubmittedHyperlinksDirectoryNumToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :submitted_hyperlinks, :text
    add_column :teams, :directory_num, :integer
  end
end
