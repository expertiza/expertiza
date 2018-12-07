class AddSupplementaryReviewQuestionnaireIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :supplementary_review_questionnaire_id, :Integer
  end
end
