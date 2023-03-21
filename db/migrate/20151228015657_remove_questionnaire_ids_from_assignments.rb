class RemoveQuestionnaireIdsFromAssignments < ActiveRecord::Migration[4.2]
  def change
    execute 'alter table assignments drop foreign key `fk_assignments_review_of_review_questionnaires`;'
    execute 'alter table assignments drop foreign key `fk_assignments_review_questionnaires`;'

    remove_column :assignments, :review_questionnaire_id
    remove_column :assignments, :review_of_review_questionnaire_id
    remove_column :assignments, :teammate_review_questionnaire_id
    remove_column :assignments, :author_feedback_questionnaire_id
    remove_column :assignments, :selfreview_questionnaire_id
    remove_column :assignments, :managerreview_questionnaire_id
    remove_column :assignments, :readerreview_questionnaire_id
  end
end
