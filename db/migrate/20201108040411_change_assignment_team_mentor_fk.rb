class ChangeAssignmentTeamMentorFk < ActiveRecord::Migration
  def change
    remove_foreign_key :assignment_team_mentors, column: :assignment_team_mentor_id
    add_foreign_key :assignment_team_mentors, :participants , column: :assignment_team_mentor_id
  end
end
