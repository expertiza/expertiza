class AlterParticipantsForSpecialRoles < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'participants', 'special_role', :string
  end

  def self.down
    remove_column 'participants', 'special_role'
  end
end
