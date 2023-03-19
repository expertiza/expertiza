class CreateParticipantScoreViews < ActiveRecord::Migration[4.2]
  def self.up
    execute <<-SQL
      CREATE VIEW participant_score_views AS SELECT r.id response_id,s.answer,q.weight,qs.name questionaire_type,qs.max_question_score,t.id as team_id,user_id as participant_id , t.parent_id as assignment_id
 FROM answers s ,responses r, response_maps rm, questions q, questionnaires qs , teams_users tu , teams t
 WHERE  rm.id = r.map_id AND r.id=s.response_id AND q.id = s.question_id AND qs.id = q.questionnaire_id    AND tu.team_id = rm.reviewee_id   AND tu.team_id = t.id
    SQL
  end

  def self.down
    execute <<-SQL
      DROP VIEW participant_score_views
    SQL
  end
end
