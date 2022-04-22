class CreateResetPassword < ActiveRecord::Migration[4.2]
  def self.up
    create_table :password_resets do |t|
      t.string :user_email
      t.string :token
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :password_resets
  end
end
