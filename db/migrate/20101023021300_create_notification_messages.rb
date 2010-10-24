class CreateNotificationMessages < ActiveRecord::Migration
  def self.up
    create_table :notification_messages do |t|
      t.string :subject
      t.string :body
      t.string :variables

      t.timestamps
    end

    NotificationMessage.create(:id => 1, :subject => "New Assignment Available",
                   :body => "<users_name>, The assignment '<assignments_name>' is now available.",
                   :variables => "users.name,assignments.name")
    NotificationMessage.create(:id => 2, :subject => "Submission Deadline",
                   :body => "<users_name>, The submission deadline for assignment '<assignments_name>' of <due_dates_due_at> is approaching.",
                   :variables => "users.name,assignments.name,due_dates.due_at")
    NotificationMessage.create(:id => 3, :subject => "Resubmission Deadline",
                   :body => "<users_name>, The resubmission deadline for assignment '<assignments_name>' of <due_dates_due_at> is approaching.",
                   :variables => "users.name,assignments.name,due_dates.due_at")
    NotificationMessage.create(:id => 4, :subject => "Review Deadline",
                   :body => "<users_name>, The review deadline for assignment '<assignments_name>' of <due_dates_due_at> is approaching.",
                   :variables => "users.name,assignments.name,due_dates.due_at")
    NotificationMessage.create(:id => 5, :subject => "Re-review Deadline",
                   :body => "<users_name>, The re-review deadline for assignment '<assignments_name>' of <due_dates_due_at> is approaching.",
                   :variables => "users.name,assignments.name,due_dates.due_at")
    NotificationMessage.create(:id => 6, :subject => "Meta-review Deadline",
                   :body => "<users_name>, The meta-review deadline for assignment '<assignments_name>' of <due_dates_due_at> is approaching.",
                   :variables => "users.name,assignments.name,due_dates.due_at")
    NotificationMessage.create(:id => 7, :subject => "Topic Granted",
                   :body => "<users_name>, Your topic selection for '<assignments_name>' has been granted.",
                   :variables => "users.name,assignments.name")
    NotificationMessage.create(:id => 8, :subject => "Review Assignment",
                   :body => "<users_name>, You have been assigned a new review for assignment '<assignments_name>'.",
                   :variables => "users.name,assignments.name")
  end

  def self.down
    drop_table :notification_messages
  end
end
