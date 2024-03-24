class CreateMentorMeetings < ActiveRecord::Migration[5.1]
  def self.up
    create_table :mentor_meetings do |t|
      t.column :team_id, :integer, null: false
      t.column :assignment_id, :integer, null: false
      t.column :meeting_date, :string, null: false
    end

    execute "ALTER TABLE `mentor_meetings`
             ADD CONSTRAINT `fk_mentor_meetings_mapping_team`
             FOREIGN KEY (team_id) references teams(id)"

    execute "ALTER TABLE `mentor_meetings`
             ADD CONSTRAINT `fk_mentor_meetings_mapping_assignment`
             FOREIGN KEY (assignment_id) references assignments(id)"

  end
end
