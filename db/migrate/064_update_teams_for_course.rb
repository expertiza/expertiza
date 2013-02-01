class UpdateTeamsForCourse < ActiveRecord::Migration
  def self.up
    begin
      execute "ALTER TABLE `teams` DROP FOREIGN KEY `fk_teams_assignments`"
    rescue
    end
   
    begin
      execute "ALTER TABLE `teams` DROP INDEX `fk_teams_assignments`"
    rescue
    end
    
    rename_column :teams, :assignment_id, :parent_id
    add_column :teams, :type, :string
    
    teams = Team.find(:all)
    teams.each{ 
      | team | 
      team.type = 'AssignmentTeam'
      team.save  
    }
  end

  def self.down
    teams = Team.find(:all)
    teams.each{ 
      | team | 
      if team.type == 'CourseTeam'
        team.delete
      end
    }
    
    remove_column :teams, :type
    rename_column :teams, :parent_id, :assignment_id
  end
end
