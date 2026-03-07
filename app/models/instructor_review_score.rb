# Stores instructor-assigned score and feedback for each peer review in a round.
class InstructorReviewScore < ApplicationRecord
  belongs_to :response
end
