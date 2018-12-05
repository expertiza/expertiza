class AddSupplementaryReviewQuestionnaireToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :supplementary_review_questionnaire, :boolean
  end
end
