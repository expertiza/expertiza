class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books, &:timestamps
  end

  def self.down
    drop_table :books
  end
end
