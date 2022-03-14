class CreateTeams < ActiveRecord::Migration[4.2]
  def self.up
    create_table :teams, id: :integer, auto_increment: true do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :teams
  end
end
