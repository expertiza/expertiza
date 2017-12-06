class AddIsJustificationRequiredFieldToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :is_justification_required, :boolean, default: false
  end
end
