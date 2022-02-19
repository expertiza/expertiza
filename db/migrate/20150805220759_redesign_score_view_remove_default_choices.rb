class RedesignScoreViewRemoveDefaultChoices < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      CREATE VIEW score_views AS SELECT ques.weight question_weight,ques.type AS type,
      q1.id "q1_id",q1.NAME AS q1_name,q1.instructor_id AS q1_instructor_id,q1.private AS q1_private,
      q1.min_question_score AS q1_min_question_score,q1.max_question_score AS q1_max_question_score,
      q1.created_at AS q1_created_at,q1.updated_at AS q1_updated_at,
      q1.TYPE AS q1_type,q1.display_type AS q1_display_type,
      ques.id as ques_id,ques.questionnaire_id as ques_questionnaire_id, s.id AS s_id,s.question_id AS s_question_id,
      s.answer AS s_score,s.comments AS s_comments,s.response_id AS s_response_id
      FROM questions ques left join questionnaires q1 on ques.questionnaire_id = q1.id left join answers s on ques.id = s.question_id

    SQL
  end
end
