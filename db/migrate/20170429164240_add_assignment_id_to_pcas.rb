class AddAssignmentIdToPcas < ActiveRecord::Migration
  def change
    add_reference :plagiarism_checker_assignment_submissions, :assignment, index: true, foreign_key: true
  end
end
