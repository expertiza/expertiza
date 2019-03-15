class CreateAccountRequests < ActiveRecord::Migration
  def change
    create_table :account_requests do |t|
      t.string :name
      t.integer :role_id
      t.string :fullname
      t.string :institution_id
      t.string :email
      t.string :status
      t.text :self_introduction

      t.timestamps null: false
    end
  end
end
