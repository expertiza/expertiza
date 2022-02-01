class DropTableTeamRoleQuestionnaire < ActiveRecord::Migration[4.2]
  def change
    drop_table :team_role_questionnaire
  end
end
