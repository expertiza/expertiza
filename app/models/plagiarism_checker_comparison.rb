class PlagiarismCheckerComparison < ApplicationRecord
  # attr_accessible :similarity_link, :similarity_percentage, :file1_name, :file1_team, :file2_name, :file2_team
  belongs_to :plagiarism_checker_assignment_submission

  # t.string :similarity_link

  # t.decimal :similarity_percentage
  validates :similarity_percentage, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 }
  # t.string :file1_name
  # t.string :file1_id
  # t.string :file1_team
  # t.string :file2_name
  # t.string :file2_id
  # t.string :file2_team
end
