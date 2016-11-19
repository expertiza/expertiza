class CreateJoinGroupRequests < ActiveRecord::Migration
  def change
    create_table :join_group_requests do |t|
      t.references :participant, index: true, foreign_key: true
      t.references :group, index: true, foreign_key: true
      t.text :comments
      t.string :status

      t.timestamps null: false
    end
  end
end
