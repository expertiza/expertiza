class PlagiarismCheckerAssignmentSubmission < ActiveRecord::Base
<<<<<<< HEAD
  attr_accessible :name
=======
  attr_accessor :name , :simicheck_id, :created_at, :updated_at
>>>>>>> Rahul and Shraddha Code Climate Fixes
  belongs_to :assignment
  has_many :plagiarism_checker_comparisons, dependent: :destroy

  # t.string :name
  validates :name, presence: true
  # t.string :simicheck_id
  validates :simicheck_id, presence: true, uniqueness: true
end
