class AddColumnToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :questionnaire_varies_by_duty, :boolean
  end
end
