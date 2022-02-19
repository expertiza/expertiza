class AddDelayedJobIdToDuedates < ActiveRecord::Migration[4.2]
  def self.up
    add_column :due_dates, :delayed_job_id, :integer
  end

  def self.down
    remove_column :due_dates, :delayed_job_id
  end
end
