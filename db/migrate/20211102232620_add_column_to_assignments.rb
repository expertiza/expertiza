class AddColumnToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :questionnaire_varies_by_duty, :boolean
  end
end
