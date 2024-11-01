class RemoveRereviewAndResubmissionDeadlines < ActiveRecord::Migration[4.2]
  def change
    execute 'alter table due_dates drop foreign key `fk_due_date_rereview_allowed`;'
    execute 'alter table due_dates drop foreign key `fk_due_date_resubmission_allowed`;'
    remove_column :due_dates, :resubmission_allowed_id
    remove_column :due_dates, :rereview_allowed_id
  end
end
