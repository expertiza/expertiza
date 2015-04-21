class CreateDropOneMemberTopicsDeadlineType < ActiveRecord::Migration
  def self.up
    DeadlineType.create :name => "drop_one_member_topics"
  end

  def self.down
    DeadlineType.find_by_name("drop_one_member_topics").destroy
  end
end
