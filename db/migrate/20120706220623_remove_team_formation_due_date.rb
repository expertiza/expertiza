class RemoveTeamFormationDueDate < ActiveRecord::Migration
  def self.up
    DeadlineType.find_by_name("team_formation").destroy
  end

  def self.down
    DeadlineType.create :name => "team_formation"
  end
end
