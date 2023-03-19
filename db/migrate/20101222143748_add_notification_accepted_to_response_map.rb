class AddNotificationAcceptedToResponseMap < ActiveRecord::Migration[4.2]
  def self.up
    add_column :response_maps, :notification_accepted, :boolean, default: false
  end

  def self.down
    remove_column :response_maps, :notification_accepted
  end
end
