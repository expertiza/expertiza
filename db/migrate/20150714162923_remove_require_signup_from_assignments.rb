class RemoveRequireSignupFromAssignments < ActiveRecord::Migration[4.2]
  def change
    remove_column 'assignments', 'require_signup'
    add_column 'assignments', 'availability_flag', :integer, default: 1
  end
end
