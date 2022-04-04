class CreatePlagiarismCheckerComparisons < ActiveRecord::Migration[4.2]
  def change
    create_table :plagiarism_checker_comparisons do |t|
      t.references :plagiarism_checker_assignment_submission, index: { name: 'assignment_submission_index' }, foreign_key: true
      t.string :similarity_link
      t.decimal :similarity_percentage
      t.string :file1_name
      t.string :file1_id
      t.string :file1_team
      t.string :file2_name
      t.string :file2_id
      t.string :file2_team

      t.timestamps null: false
    end
  end
end
