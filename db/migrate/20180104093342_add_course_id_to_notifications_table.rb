class AddCourseIdToNotificationsTable < ActiveRecord::Migration
  def change
  	add_reference :notifications, :course, index: true
  end
end
