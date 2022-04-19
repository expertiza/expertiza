class AddLockToResponses < ActiveRecord::Migration
  def change
    create_table :locks do |t|
      t.integer :timeout_period
      t.timestamps
    end
    add_reference :locks, :user, foreign_key: true
    add_reference :locks, :lockable, polymorphic: true
  end
end
