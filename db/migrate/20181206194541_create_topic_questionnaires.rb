class CreateTopicQuestionnaires < ActiveRecord::Migration
def self.up

  create_table :topic_questionnaires do |t|
    t.integer :sign_up_topic_id, null:true
    t.integer :questionnaire_id, null:true
    t.integer :used_in_round, null:true

    t.timestamps null: false
  end

  execute 'ALTER TABLE `topic_questionnaires`
             ADD CONSTRAINT fk_tq_topics_id
             FOREIGN KEY (sign_up_topic_id) REFERENCES sign_up_topics(id)'


  execute 'ALTER TABLE `topic_questionnaires`
             ADD CONSTRAINT fk_tq_questionnaire_id
             FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id)'
end

def self.down
  drop_table :topic_questionnaires
end
end