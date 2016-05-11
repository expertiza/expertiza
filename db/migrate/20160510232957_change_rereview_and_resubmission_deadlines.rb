class ChangeRereviewAndResubmissionDeadlines < ActiveRecord::Migration
  def change
    resubmission_deadlines = DueDate.where(:deadline_type_id=>3)
    resubmission_deadlines.each do |resubmission_deadline|
      resubmission_deadline.deadline_type = 1
      resubmission_deadline.submission_allowed_id=3
      resubmission_deadline.save
    end

    rereview_deadlines = DueDate.where(:deadline_type_id=>4)
    rereview_deadlines.each do |resubmission_deadline|
      rereview_deadline.deadline_type = 2
      rereview_deadline.submission_allowed_id=3
      rereview_deadline.save
    end
  end
end
