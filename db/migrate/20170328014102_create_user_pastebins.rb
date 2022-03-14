class CreateUserPastebins < ActiveRecord::Migration[4.2]
  def change
    create_table :user_pastebins, id: :integer, auto_increment: true do |t|
      t.integer :user_id
      t.string :short_form
      t.text :long_form

      t.timestamps null: false
    end
  end
end
