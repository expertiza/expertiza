class RemoveRequireSignupFromAssignment < ActiveRecord::Migration
  def change
    remove_column "assignments","availability_flag"
  end
end
