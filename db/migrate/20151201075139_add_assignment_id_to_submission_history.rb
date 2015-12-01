class AddAssignmentIdToSubmissionHistory < ActiveRecord::Migration
  def self.up
    add_column :submission_histories, :assignment_id, :integer
  end

  def self.down
  end
end
