class DropTableTag < ActiveRecord::Migration[4.2]
  def change
    drop_table :tags
  end
end
