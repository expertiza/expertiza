class CreateAssignmentTeamMentors < ActiveRecord::Migration
  def change
    create_table :assignment_team_mentors do |t|
      t.integer :assignment_team_id
      t.integer :assignment_team_mentor_id
    end
    
    add_foreign_key :assignment_team_mentors, :teams , column: :assignment_team_id
    add_foreign_key :assignment_team_mentors, :users , column: :assignment_team_mentor_id
  end
end
