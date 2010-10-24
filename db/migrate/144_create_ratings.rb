class CreateRatings< ActiveRecord::Migration

  def self.up
    create_table :ratings, :force => true do |t|
      t.column :rating, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
      t.column :rateable_type, :string, :limit => 15,
      :default => "", :null => false
      t.column :rateable_id, :integer, :default => 0, :null => false
      t.column :user_id, :integer, :default => 0, :null => false
    end

    add_index :ratings, ["user_id"], :name => "fk_ratings_user"
  end

  def self.down
    drop_table :ratings
  end
end
