class CreateNewDeadlineTypes < ActiveRecord::Migration
  def self.up
        DeadlineType.create :name => "signup"
        DeadlineType.create :name => "team_formation"
  end

  def self.down
        DeadlineType.find_by_name("signup").destroy
        DeadlineType.find_by_name("team_formation").destroy
  end
end
