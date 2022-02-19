class CreatePlagiarismCheckerAssignmentSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :plagiarism_checker_assignment_submissions do |t|
      t.string :name
      t.string :simicheck_id

      t.timestamps null: false
    end
  end
end
