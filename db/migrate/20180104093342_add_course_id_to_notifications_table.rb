class AddCourseIdToNotificationsTable < ActiveRecord::Migration[4.2]
  def change
    add_reference :notifications, :course, index: true
  end
end
