class RemoveSubmittedHyperlinksDirectoryNumFromParticipants < ActiveRecord::Migration
  def change
    remove_column :participants, :submitted_hyperlinks, :text
    remove_column :participants, :directory_num, :integer
  end
end
