class Suggestion < ActiveRecord::Base
  validates_presence_of :title, :description
  has_many :suggestion_comments

  def where(assignment_id: assignment_id)
    where(["assignment_id = ?", assignment_id])
  end
end
