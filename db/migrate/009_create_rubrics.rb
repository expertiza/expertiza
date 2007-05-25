class CreateRubrics < ActiveRecord::Migration
  def self.up
    create_table :rubrics do |t|
      t.column :name, :string, :limit=>64
      t.column :instructor_id, :integer # id of instructor who created the rubric
      t.column :private, :boolean  # whether rubric is visible to other instructors
      t.column :min_question_score, :integer # the minimum score that the reviewer can give for a question in this rubric
      t.column :max_question_score, :integer # the maximum score that the reviewer can give for a question in this rubric
    end
    execute "alter table rubrics
             add constraint fk_rubrics_instructors
             foreign key (instructor_id) references users(id)"
  end

  def self.down
    drop_table :rubrics
  end
end
