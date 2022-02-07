class CreateQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :questionnaires do |t|
      t.column :name, :string, :limit=>64
      t.column :instructor_id, :integer # id of instructor who created the questionnaire
      t.column :private, :boolean  # whether questionnaire is visible to other instructors
      t.column :min_question_score, :integer # the minimum score that the reviewer can give for a question in this questionnaire
      t.column :max_question_score, :integer # the maximum score that the reviewer can give for a question in this questionnaire
    end
    execute "alter table questionnaires
             add constraint fk_questionnaires_instructors
             foreign key (instructor_id) references users(id)"
  end

  def self.down
    drop_table :questionnaires
  end
end
