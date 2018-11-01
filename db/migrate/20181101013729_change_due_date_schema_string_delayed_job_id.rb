class ChangeDueDateSchemaStringDelayedJobId < ActiveRecord::Migration
  def change
    change_table :due_dates do |t|
      t.change :delayed_job_id, :string
    end
  end
end
