class AddMakePublicToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :make_public, :boolean, default: false
  end
end
