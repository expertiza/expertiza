class AddDeadlineNameAndDescriptionUrlToDueDates < ActiveRecord::Migration
  def self.up
    add_column "due_dates","deadline_name",:string
    add_column "due_dates","description_url",:string
  end

  def self.down
    remove_column "due_dates","deadline_name"
    remove_column "due_dates","description_url"
  end
end