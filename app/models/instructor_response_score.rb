# Stores instructor-assigned score and feedback for individual peer review responses.
# One record per Response (peer review).
class InstructorResponseScore < ApplicationRecord
  belongs_to :response
end
