class RemoveRereviewAndResubmissionDeadlineTypes < ActiveRecord::Migration[4.2]
  def change
    DeadlineType.find_by(name: 'resubmission').delete
    DeadlineType.find_by(name: 'rereview').delete
  end
end
