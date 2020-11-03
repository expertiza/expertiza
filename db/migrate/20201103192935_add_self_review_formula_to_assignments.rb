class AddSelfReviewFormulaToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :self_review_formula, :string, default: 'None'
  end
end




