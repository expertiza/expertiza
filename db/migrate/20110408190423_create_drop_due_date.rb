class CreateDropDueDate < ActiveRecord::Migration
  def self.up
    DeadlineType.create :name => "drop topic"
  end

  def self.down
    DeadlineType.find(:conditions => {:name => "drop topic"}).destroy
  end
end
