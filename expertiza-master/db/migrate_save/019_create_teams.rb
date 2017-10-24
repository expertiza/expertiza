class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :teams
  end
end
