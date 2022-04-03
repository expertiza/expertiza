class RenameIsLottery < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :assignments, :is_lottery, :is_intelligent
  end

  def self.down
    rename_column :assignments, :is_intelligent, :is_lottery
  end
end
