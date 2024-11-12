class GithubMetricUses < ActiveRecord::Base

  def initialize(assignment_id)
    super()
    @assignment_id = assignment_id
  end

  def self.record_exists?(assignment_id)
    exists?(assignment_id: assignment_id)
  end
  
end
