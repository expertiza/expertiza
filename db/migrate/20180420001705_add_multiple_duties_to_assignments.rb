class AddMultipleDutiesToAssignments < ActiveRecord::Migration
  def change
  	add_column :assignments , :allow_multiple_duties, :boolean
  end
end
