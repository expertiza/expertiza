class AddPermissionUpdatedAtToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :permission_updated_at, :datetime
  end

  def self.down
    remove_column :participants, :permission_updated_at
  end
end
