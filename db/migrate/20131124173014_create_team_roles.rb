class CreateTeamRoles < ActiveRecord::Migration
  def self.up
    create_table "team_roles", :force => true do |t|
      #t.integer "id"
      t.string "role_names"
      t.integer "questionnaire_id"
    end
    execute "ALTER TABLE `team_roles`
             ADD CONSTRAINT `fk_team_roles_questionnaire`
             FOREIGN KEY (questionnaire_id) references questionnaires(id)"

  end

  def self.down
    execute "ALTER TABLE `team_roles`
             DROP FOREIGN KEY `fk_team_roles_questionnaire`"
    drop_table :team_roles
  end
end
