class RemoveCommentsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :comments
  end
end
