class CreateBmappingRatings < ActiveRecord::Migration[4.2]
  def self.up
    if table_exists?(:bmapping_ratings) == false
      create_table :bmapping_ratings, id: :integer, auto_increment: true do |t|
        t.column 'bmapping_id', :integer, null: false
        t.column 'user_id', :integer, null: false
        t.column 'rating', :integer, null: false
        t.timestamps
      end
    end
  end

  def self.down
    drop_table :bmapping_ratings
  end
end
