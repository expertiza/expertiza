class DropTableTag < ActiveRecord::Migration
  def change
    drop_table :tags
  end
end
