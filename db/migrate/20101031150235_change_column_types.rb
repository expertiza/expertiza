class ChangeColumnTypes < ActiveRecord::Migration
  def self.up
    #changing type from string to text so that long descriptions can be supported
    change_column :suggestions, :title,:text
    change_column :suggestions,:description,:text
  end

  def self.down
  end
end
