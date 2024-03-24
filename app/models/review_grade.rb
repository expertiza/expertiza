class ReviewGrade < ApplicationRecord
  belongs_to :participant

  def self.find_graded_member(graded_member)
    Assignment.find(graded_member.parent_id)
  end
end
