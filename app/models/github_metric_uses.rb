class GithubMetricUses < ActiveRecord::Base

  def initialize(assignment_id)
    super()
    @assignment_id = assignment_id
  end
end
