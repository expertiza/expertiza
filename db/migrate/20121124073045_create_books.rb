class CreateBooks < ActiveRecord::Migration[4.2]
  def self.up
    create_table :books, &:timestamps
  end

  def self.down
    drop_table :books
  end
end
