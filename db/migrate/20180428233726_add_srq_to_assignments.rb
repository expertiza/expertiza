class AddSrqToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :srq, :boolean
  end
end
