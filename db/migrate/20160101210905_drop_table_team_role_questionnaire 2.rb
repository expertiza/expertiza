class DropTableTeamRoleQuestionnaire < ActiveRecord::Migration
  def change
    drop_table :team_role_questionnaire
  end
end
