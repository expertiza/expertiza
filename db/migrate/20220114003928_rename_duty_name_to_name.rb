class RenameDutyNameToName < ActiveRecord::Migration
  def change
    rename_column :duties, :duty_name, :name
  end
end
