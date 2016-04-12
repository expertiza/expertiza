class CreateTableBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.column "badge_id", :integer, :null => false
      t.column "name", :string, :default => "", :null => false
    end
  end
end
