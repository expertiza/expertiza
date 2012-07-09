class AddVersionNumToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :version_num, :integer
  end

  def self.down
    remove_column :responses, :version_num
  end
end
