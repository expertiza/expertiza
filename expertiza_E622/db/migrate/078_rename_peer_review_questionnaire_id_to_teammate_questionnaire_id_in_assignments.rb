class RenamePeerReviewQuestionnaireIdToTeammateQuestionnaireIdInAssignments < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `assignments` CHANGE `peer_review_questionnaire_id` `teammate_review_questionnaire_id` INT( 10 ) NULL DEFAULT NULL"
  end

  def self.down
    execute "ALTER TABLE `assignments` CHANGE `teammate_review_questionnaire_id` `peer_review_questionnaire_id` INT( 10 ) NULL DEFAULT NULL"
  end
end
