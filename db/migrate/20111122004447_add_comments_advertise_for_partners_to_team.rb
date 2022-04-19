class AddCommentsAdvertiseForPartnersToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :comment, :text
    add_column :teams, :advertise_for_partner, :boolean
  end

  def self.down
    remove_column :teams, :advertise_for_partner
    remove_column :teams, :comment
  end
end
