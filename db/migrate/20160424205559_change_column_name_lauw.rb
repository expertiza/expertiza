class ChangeColumnNameLauw < ActiveRecord::Migration
  def change
    rename_column :assignments, :Lauw, :lauw
  end
end
