class AuthorFeedback < ActiveRecord::Migration
  def self.up
     add_column "assignments","author_feedback_questionnaire_id",:integer
     
     execute "ALTER TABLE assignments ADD CONSTRAINT `fk_assignments_author_feedback` FOREIGN KEY (author_feedback_questionnaire_id) REFERENCES questionnaire_types(id);"
     
     #QuestionnaireType.create(
      #:name => 'Author Feedback'
     #)
  end

  def self.down
      execute "DELETE from `questionnaire_types` where name = 'Author Feedback'"
      execute "ALTER TABLE `assignments` DROP FOREIGN KEY `fk_assignments_author_feedback`"
      remove_column "assignments","author_feedback_questionnaire_id"
  end
end
