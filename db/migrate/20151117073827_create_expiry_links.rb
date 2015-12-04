class CreateExpiryLinks < ActiveRecord::Migration
  def change
    create_table :expiry_links do |t|
      t.string :email
      t.string :link

      t.timestamps null: false
    end
  end
end
