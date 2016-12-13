class RenameResponsetimesTable < ActiveRecord::Migration
  def change
    rename_table :responsetimes, :response_times
  end
end
