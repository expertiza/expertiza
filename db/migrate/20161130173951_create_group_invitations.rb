class CreateGroupInvitations < ActiveRecord::Migration
  def change
    create_table :group_invitations do |t|
      t.references :assignment, index: true, foreign_key: true
      t.references :from, references: :users
      t.references :to, references: :users
      t.column :reply_status, :char
      t.timestamps null: false
    end
  end
end
