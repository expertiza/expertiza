class CreateScoreViews < ActiveRecord::Migration

    def self.up
      execute <<-SQL
      CREATE VIEW score_views AS SELECT ques.weight question_weight,q.id AS q_id,q.q_type AS q_type,q.parameters AS q_parameters,q.question_id AS q_question_id,
      q1.id "q1_id",q1.NAME AS q1_name,q1.instructor_id AS q1_instructor_id,q1.private AS q1_private,
      q1.min_question_score AS q1_min_question_score,q1.max_question_score AS q1_max_question_score,
      q1.created_at AS q1_created_at,q1.updated_at AS q1_updated_at,q1.default_num_choices AS q1_default_num_choices,
      q1.TYPE AS q1_type,q1.display_type AS q1_display_type,q1.section AS q1_section,q1.instruction_loc AS q1_instruction_loc,
      ques.id as ques_id,ques.questionnaire_id as ques_questionnaire_id, s.id AS s_id,s.question_id AS s_question_id,
      s.score AS s_score,s.comments AS s_comments,s.response_id AS s_response_id
      FROM questions ques left join question_types q on ques.id = q.question_id
      left join questionnaires q1 on ques.questionnaire_id = q1.id left join scores s on ques.id = s.question_id
      SQL
    end
    def self.down
      execute <<-SQL
      DROP VIEW score_views
      SQL
    end

end
