class AddAutoAssignMentorColumn < ActiveRecord::Migration
  def change
    add_column :assignments, :auto_assign_mentor, :boolean, default: false
  end
end
