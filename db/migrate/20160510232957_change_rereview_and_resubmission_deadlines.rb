class ChangeRereviewAndResubmissionDeadlines < ActiveRecord::Migration[4.2]
  def change
    resubmission_deadlines = DueDate.where(deadline_type_id: 3)
    resubmission_deadlines.each do |resubmission_deadline|
      resubmission_deadline.deadline_type_id = 1
      resubmission_deadline.submission_allowed_id = 3
      resubmission_deadline.save
    end

    rereview_deadlines = DueDate.where(deadline_type_id: 4)
    rereview_deadlines.each do |rereview_deadline|
      rereview_deadline.deadline_type_id = 2
      rereview_deadline.submission_allowed_id = 3
      rereview_deadline.save
    end
  end
end
