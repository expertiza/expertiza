class CreateTeamRoleQuestionnaire < ActiveRecord::Migration
  def self.up
    create_table "team_role_questionnaire", :force  => true do |t|
      #t.integer :id
      t.integer :team_roles_id
      t.integer :questionnaire_id
      t.timestamps

    end
    execute "ALTER TABLE `team_role_questionnaire`
    ADD CONSTRAINT fk_team_roles_id
    FOREIGN KEY (team_roles_id) references team_roles(id)"
    execute "ALTER TABLE `team_role_questionnaire`
    ADD CONSTRAINT fk_questionnaire_id
    FOREIGN KEY (questionnaire_id) references questionnaires(id)"
  end

  def self.down
    execute "ALTER TABLE `team_role_questionnaire`
    DROP FOREIGN KEY fk_team_roles_id"
    execute "ALTER TABLE `team_role_questionnaire`
    DROP FOREIGN KEY fk_questionnaire_id"
    drop_table :team_role_questionnaire
  end
end
