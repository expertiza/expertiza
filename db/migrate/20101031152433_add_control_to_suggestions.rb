class AddControlToSuggestions < ActiveRecord::Migration
  #adding control bit to suggestion table and adding timestamps as well.
  def self.up
    add_column :suggestions, :control, :int, :default=>0
    
    change_table :suggestions do |t|
  t.timestamps
end
  end

  def self.down
    remove_column :suggestions, :control
  end
end
