class CreateBooks < ActiveRecord::Migration[4.2]
  def self.up
    create_table :books, id: :integer, auto_increment: true, &:timestamps
  end

  def self.down
    drop_table :books
  end
end
