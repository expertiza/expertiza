class AddDutyFlaginAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :duty_flag, :boolean, default: false
  end
end
