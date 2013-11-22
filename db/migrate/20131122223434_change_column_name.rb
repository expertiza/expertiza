class ChangeColumnName < ActiveRecord::Migration
  def self.up
    rename_column :assignments, :is_lottery, :is_intelligent
  end

  def self.down
  end
end
