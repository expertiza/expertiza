class AddLockToResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :locks, id: :integer, auto_increment: true do |t|
      t.integer :timeout_period
      t.timestamps
    end
    add_reference :locks, :user, foreign_key: true
    add_reference :locks, :lockable, polymorphic: true
  end
end
