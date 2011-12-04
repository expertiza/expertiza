class CreateBmappingRatings < ActiveRecord::Migration
  def self.up
    create_table :bmapping_ratings do |t|
      t.column "bmapping_id", :integer, :null=> false
      t.column "user_id", :integer, :null => false
      t.column "rating", :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :bmapping_ratings
  end
end

