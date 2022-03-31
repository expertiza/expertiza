class UpdateTeamsForCourse < ActiveRecord::Migration[4.2]
  def self.up
    begin
      execute 'ALTER TABLE `teams` DROP FOREIGN KEY `fk_teams_assignments`'
    rescue StandardError
    end

    begin
      execute 'ALTER TABLE `teams` DROP INDEX `fk_teams_assignments`'
    rescue StandardError
    end

    rename_column :teams, :assignment_id, :parent_id
    add_column :teams, :type, :string

    teams = Team.all
    teams.each  do |team|
      team.type = 'AssignmentTeam'
      team.save
    end
  end

  def self.down
    teams = Team.all
    teams.each do |team|
      team.delete if team.type == 'CourseTeam'
    end

    remove_column :teams, :type
    rename_column :teams, :parent_id, :assignment_id
  end
end
