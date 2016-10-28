class RemoveNotificationAcceptedFromResponseMap < ActiveRecord::Migration
  def change
    remove_column "response_maps","notification_accepted"
  end
end
