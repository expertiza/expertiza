class RemoveSumittedHyperlinkAndDirNumFromParticipants < ActiveRecord::Migration[4.2]
  def change
    remove_column :participants, :submitted_hyperlinks
    remove_column :participants, :directory_num
  end
end
