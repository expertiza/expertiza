class Repl0ValsInAuthFb < ActiveRecord::Migration
  def self.up
    execute " ALTER TABLE `assignments` CHANGE `author_feedback_questionnaire_id` `author_feedback_questionnaire_id` INT( 11 ) NULL"
    execute "UPDATE `assignments` SET `author_feedback_questionnaire_id` = NULL WHERE `author_feedback_questionnaire_id` = 0"
  end

  def self.down
  end
end
