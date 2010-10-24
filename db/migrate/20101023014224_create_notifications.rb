class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :description
      t.string :base_data_type
      t.string :relationship
      t.references :notification_message

      t.timestamps
    end

    Notification.create(:id => 1, :description => "New Assignment Notification",
                        :base_data_type => "Participant",
                        :relationship => "assignments.id=participants.parent_id,users.id=participants.user_id",
                        :notification_message_id => 1)
    Notification.create(:id => 2, :description => "Submission Deadline Reminder",
                        :base_data_type => "Assignment",
                        :relationship => "due_dates.assignment_id=assignments.id,participants.parent_id=assignments.id,users.id=participants.user_id",
                        :notification_message_id => 2)
    Notification.create(:id => 3, :description => "Re-submission Deadline Reminder",
                        :base_data_type => "Assignment",
                        :relationship => "due_dates.assignment_id=assignments.id,participants.parent_id=assignments.id,users.id=participants.user_id",
                        :notification_message_id => 3)
    Notification.create(:id => 4, :description => "Review Deadline Reminder",
                        :base_data_type => "Assignment",
                        :relationship => "due_dates.assignment_id=assignments.id,participants.parent_id=assignments.id,users.id=participants.user_id",
                        :notification_message_id => 4)
    Notification.create(:id => 5, :description => "Re-review Deadline Reminder",
                        :base_data_type => "Assignment",
                        :relationship => "due_dates.assignment_id=assignments.id,participants.parent_id=assignments.id,users.id=participants.user_id",
                        :notification_message_id => 5)
    Notification.create(:id => 6, :description => "Meta-review Deadline Reminder",
                        :base_data_type => "Assignment",
                        :relationship => "due_dates.assignment_id=assignments.id,participants.parent_id=assignments.id,users.id=participants.user_id",
                        :notification_message_id => 6)
    Notification.create(:id => 7, :description => "Topic Granted Notification",
                        :base_data_type => "SignedUpUser",
                        :relationship => "sign_up_topics.id=signed_up_users.topic_id,assignments.id=sign_up_topics.assignment_id,users.id=signed_up_users.creator_id",
                        :notification_message_id => 7)
    Notification.create(:id => 8, :description => "New Review Assigned Notification",
                        :base_data_type => "ResponseMap",
                        :relationship => "participants.id=response_maps.reviewer_id,users.id=participants.user_id,assignments.id=response_maps.reviewed_object_id",
                        :notification_message_id => 8)
  end

  def self.down
    drop_table :notifications
  end
end
