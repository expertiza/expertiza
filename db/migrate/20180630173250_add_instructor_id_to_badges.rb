class AddInstructorIdToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :instructor_id, :integer
  end
end
