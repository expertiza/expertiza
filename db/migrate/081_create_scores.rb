class CreateScores < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE `scores` (
        `id` int(11) NOT NULL auto_increment,
        `instance_id` int(11) NOT NULL,
        `question_id` int(11) NOT NULL,
        `score` int(11) default NULL,
        `comments` text,
        `questionnaire_type_id` int(11) NOT NULL,
        PRIMARY KEY  (`id`),
        KEY `fk_score_questions` (`question_id`),
        KEY `fk_score_questionnaire_types` (`questionnaire_type_id`),
        CONSTRAINT `fk_score_questions` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`),
        CONSTRAINT `fk_score_questionnaire_types` FOREIGN KEY (`questionnaire_type_id`) REFERENCES `questionnaire_types` (`id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1"
  end
  def self.down
    execute 'ALTER TABLE scores DROP FOREIGN KEY fk_score_questions'
    execute 'ALTER TABLE scores DROP FOREIGN KEY `fk_score_questionnaire_types'
    execute 'DROP TABLE scores'
  end
end
