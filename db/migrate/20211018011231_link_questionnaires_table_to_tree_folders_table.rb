class LinkQuestionnairesTableToTreeFoldersTable < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW score_views
    SQL

    execute <<-SQL
      INSERT INTO tree_folders (name, child_type, parent_id)
      VALUES ('Survey', 'QuestionnaireNode',1), ('Course Evaluation', 'QuestionnaireNode',1)
    SQL

    add_reference :questionnaires, :tree_folder

    execute <<-SQL
      UPDATE questionnaires
      INNER JOIN tree_folders 
      ON REPLACE(tree_folders.name,' ','') = REPLACE(REPLACE(questionnaires.display_type, ' ', ''), '%', '')
      SET questionnaires.tree_folder_id = tree_folders.id
    SQL

    add_foreign_key :questionnaires, :tree_folders, name: :tree_folder_id
    remove_column :questionnaires, :display_type

    execute <<-SQL
      CREATE VIEW score_views AS SELECT ques.weight question_weight,ques.type AS type,
      q1.id "q1_id",q1.NAME AS q1_name,q1.instructor_id AS q1_instructor_id,q1.private AS q1_private,
      q1.min_question_score AS q1_min_question_score,q1.max_question_score AS q1_max_question_score,
      q1.created_at AS q1_created_at,q1.updated_at AS q1_updated_at,
      q1.TYPE AS q1_type,q1.display_type AS q1_display_type,
      ques.id as ques_id,ques.questionnaire_id as ques_questionnaire_id, s.id AS s_id,s.question_id AS s_question_id,
      s.answer AS s_score,s.comments AS s_comments,s.response_id AS s_response_id
      FROM 
        questions ques 
      LEFT JOIN 
        (
          SELECT 
            q.id AS id, q.name AS name, q.instructor_id as instructor_id, 
            q.private as private, q.min_question_score as min_question_score, 
            q.max_question_score as max_question_score, q.created_at as created_at,
            q.updated_at as updated_at, q.type as type, t.name as display_type
          FROM questionnaires q 
          INNER JOIN tree_folders t ON q.tree_folder_id = t.id
        ) q1 ON ques.questionnaire_id = q1.id 
      LEFT JOIN answers s ON ques.id = s.question_id
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW score_views
    SQL

    add_column :questionnaires, :display_type, :string

    execute <<-SQL
      UPDATE questionnaires
      INNER JOIN tree_folders 
      ON tree_folders.id = questionnaires.tree_folder_id
      SET questionnaires.display_type = tree_folders.name
    SQL

    remove_foreign_key :questionnaires, :tree_folders

    remove_reference :questionnaires, :tree_folder

    execute <<-SQL
      DELETE FROM tree_folders
      WHERE tree_folders.name in ('Survey', 'Course Evaluation')
    SQL

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
