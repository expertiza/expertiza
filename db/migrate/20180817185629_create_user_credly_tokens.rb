class CreateUserCredlyTokens < ActiveRecord::Migration
  def change
    create_table :user_credly_tokens do |t|
      t.references :user, index: true, foreign_key: true
      t.string :access_token
      t.string :refresh_token
      t.timestamps null: false
    end
  end
end
