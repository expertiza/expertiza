class CreateDropDueDate < ActiveRecord::Migration
  def self.up
    DeadlineType.create :name => "drop topic"
  end

  def self.down
    DeadlineType.find_by_name("drop topic").destroy
  end
end
