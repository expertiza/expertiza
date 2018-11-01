class ChangeDueDateSchemaStringDelayedJobId < ActiveRecord::Migration
  def change
    change_table :due_date do |t|
      t.change :delayed_job_id, :string
    end
  end
end
