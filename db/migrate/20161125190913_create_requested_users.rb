class CreateRequestedUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :requested_users do |t|
      t.string :name
      t.integer :role_id
      t.string :fullname
      t.string :institution_id
      t.string :email
      t.string :status
      t.string :reason

      t.timestamps null: false
    end
  end
end
