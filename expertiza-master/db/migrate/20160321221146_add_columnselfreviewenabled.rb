#E1600
class AddColumnselfreviewenabled < ActiveRecord::Migration
  def self.up
    add_column :assignments, :is_selfreview_enabled, :boolean
  end

  def self.down
    remove_column :assignments, :is_selfreview_enabled, :boolean
  end
end
