class CreateMetaConditions < ActiveRecord::Migration
  def self.up
    create_table :meta_conditions do |t|
      t.references :notification
      t.string :data_name
      t.string :condition
      t.string :comparison_value

      t.timestamps
    end

    # New assignment notification
    MetaCondition.create(:notification_id => 1, :data_name => "participants.created_at", :condition => ">", :comparison_value => "Time.now.getutc - 1.hour")
    MetaCondition.create(:notification_id => 1, :data_name => "participants.created_at", :condition => "<", :comparison_value => "Time.now.getutc")

    # Submission reminder
    MetaCondition.create(:notification_id => 2, :data_name => "due_dates.due_at", :condition => ">", :comparison_value => "Time.now")
    MetaCondition.create(:notification_id => 2, :data_name => "due_dates.due_at", :condition => "<", :comparison_value => "Time.now + 1.hour")
    MetaCondition.create(:notification_id => 2, :data_name => "due_dates.deadline_type_id", :condition => "=", :comparison_value => "1")

    # Resubmission reminder
    MetaCondition.create(:notification_id => 3, :data_name => "due_dates.due_at", :condition => ">", :comparison_value => "Time.now")
    MetaCondition.create(:notification_id => 3, :data_name => "due_dates.due_at", :condition => "<", :comparison_value => "Time.now + 1.hour")
    MetaCondition.create(:notification_id => 3, :data_name => "due_dates.deadline_type_id", :condition => "=", :comparison_value => "3")

    # Review reminder
    MetaCondition.create(:notification_id => 4, :data_name => "due_dates.due_at", :condition => ">", :comparison_value => "Time.now")
    MetaCondition.create(:notification_id => 4, :data_name => "due_dates.due_at", :condition => "<", :comparison_value => "Time.now + 1.hour")
    MetaCondition.create(:notification_id => 4, :data_name => "due_dates.deadline_type_id", :condition => "=", :comparison_value => "2")

    # Re-review reminder
    MetaCondition.create(:notification_id => 5, :data_name => "due_dates.due_at", :condition => ">", :comparison_value => "Time.now")
    MetaCondition.create(:notification_id => 5, :data_name => "due_dates.due_at", :condition => "<", :comparison_value => "Time.now + 1.hour")
    MetaCondition.create(:notification_id => 5, :data_name => "due_dates.deadline_type_id", :condition => "=", :comparison_value => "4")

    # Meta-review reminder
    MetaCondition.create(:notification_id => 6, :data_name => "due_dates.due_at", :condition => ">", :comparison_value => "Time.now")
    MetaCondition.create(:notification_id => 6, :data_name => "due_dates.due_at", :condition => "<", :comparison_value => "Time.now + 1.hour")
    MetaCondition.create(:notification_id => 6, :data_name => "due_dates.deadline_type_id", :condition => "=", :comparison_value => "5")

    # Topic granted notification
    MetaCondition.create(:notification_id => 7, :data_name => "signed_up_users.updated_at", :condition => ">", :comparison_value => "Time.now.getutc - 1.hour")
    MetaCondition.create(:notification_id => 7, :data_name => "signed_up_users.updated_at", :condition => "<", :comparison_value => "Time.now.getutc")
    MetaCondition.create(:notification_id => 7, :data_name => "signed_up_users.is_waitlisted", :condition => "=", :comparison_value => "false")

    # New review notification
    MetaCondition.create(:notification_id => 8, :data_name => "response_maps.created_at", :condition => ">", :comparison_value => "Time.now.getutc - 1.hour")
    MetaCondition.create(:notification_id => 8, :data_name => "response_maps.created_at", :condition => "<", :comparison_value => "Time.now.getutc")
  end

  def self.down
    drop_table :meta_conditions
  end
end
