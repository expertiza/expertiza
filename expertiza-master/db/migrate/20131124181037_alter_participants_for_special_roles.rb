class AlterParticipantsForSpecialRoles < ActiveRecord::Migration
  def self.up
    add_column "participants","special_role",:string

  end

  def self.down
    remove_column "participants","special_role"
  end
end