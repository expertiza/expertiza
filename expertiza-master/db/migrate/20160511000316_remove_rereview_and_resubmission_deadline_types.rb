class RemoveRereviewAndResubmissionDeadlineTypes < ActiveRecord::Migration
  def change
    DeadlineType.find_by(name: "resubmission").delete
    DeadlineType.find_by(name: "rereview").delete
  end
end
