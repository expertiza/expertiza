class AddTimestampsToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :created_at, :datetime
    add_column :participants, :updated_at, :datetime
  end

  def self.down
    remove_column :participants, :created_at
    remove_column :participants, :updated_at
  end
end
