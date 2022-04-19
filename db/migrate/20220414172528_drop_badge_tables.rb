class DropBadgeTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :awarded_badges
    drop_table :badges
  end
end
