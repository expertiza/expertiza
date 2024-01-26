class PlagiarismCheckerAssignmentSubmission < ApplicationRecord
  # attr_accessible :name
  belongs_to :assignment
  has_many :plagiarism_checker_comparisons, dependent: :destroy

  # t.string :name
  validates :name, presence: true
  # t.string :simicheck_id
  validates :simicheck_id, presence: true, uniqueness: true
end
