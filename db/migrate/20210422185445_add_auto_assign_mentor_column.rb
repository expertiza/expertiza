class AddAutoAssignMentorColumn < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :auto_assign_mentor, :boolean, default: false
  end
end
