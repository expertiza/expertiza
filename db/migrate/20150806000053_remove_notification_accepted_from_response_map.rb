class RemoveNotificationAcceptedFromResponseMap < ActiveRecord::Migration[4.2]
  def change
    remove_column 'response_maps', 'notification_accepted'
  end
end
