class AddNameInAssignments < ActiveRecord::Migration
  def change
    rename_column :assignments , :is_calibrated , :has_expert_review
  end
end
