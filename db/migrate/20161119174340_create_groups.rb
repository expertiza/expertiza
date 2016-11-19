class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.boolean :isAnonymous
      t.string :name
      t.integer :parent_id
      t.string :type
      t.text :comments_for_advertisement
      t.boolean :advertise_for_partners

      t.timestamps null: false
    end
  end
end
