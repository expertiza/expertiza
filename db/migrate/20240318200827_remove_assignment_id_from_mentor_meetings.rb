class RemoveAssignmentIdFromMentorMeetings < ActiveRecord::Migration[5.1]
  def up
    # Remove the foreign key constraint
    execute "ALTER TABLE `mentor_meetings` DROP FOREIGN KEY `fk_mentor_meetings_mapping_assignment`"

    # Remove the column
    remove_column :mentor_meetings, :assignment_id
  end
end
