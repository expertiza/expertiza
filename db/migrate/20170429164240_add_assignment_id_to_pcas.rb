class AddAssignmentIdToPcas < ActiveRecord::Migration[4.2]
  def change
    add_reference :plagiarism_checker_assignment_submissions, :assignment, index: { name: 'index_plagiarism_checker_assgt_subm_on_assignment_id' }, foreign_key: true
  end
end
