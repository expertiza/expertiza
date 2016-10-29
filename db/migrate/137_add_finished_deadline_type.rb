class DeadlineType < ActiveRecord::Migration
  def self.up
    DeadlineType.create :name => "Finished", :id => 0
  end

  def self.down
    DeadlineType.destroy(0)
  end
end
