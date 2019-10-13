class ChangeDueDateSchemaStringDelayedJobId < ActiveRecord::Migration
  def change
    change_table :due_dates do |t|
      # Sidekiq jobs have string job id, hence this change
      t.change :delayed_job_id, :string
    end
  end
end
