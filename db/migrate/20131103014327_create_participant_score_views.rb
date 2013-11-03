class CreateParticipantScoreViews < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE VIEW participant_score_views AS SELECT r.id response_id,s.score,q.weight,qs.name questionaire_type,qs.max_question_score,reviewee_id
 FROM scores s ,responses r, response_maps rm, questions q, questionnaires qs
 WHERE  rm.id = r.map_id AND r.id=s.response_id AND q.id = s.question_id AND qs.id = q.questionnaire_id
    SQL
  end
  def self.down
    execute <<-SQL
      DROP VIEW participant_score_views
    SQL
  end
end
