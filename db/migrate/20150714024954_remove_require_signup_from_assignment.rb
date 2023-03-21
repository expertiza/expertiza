class RemoveRequireSignupFromAssignment < ActiveRecord::Migration[4.2]
  def change
    remove_column 'assignments', 'availability_flag'
  end
end
