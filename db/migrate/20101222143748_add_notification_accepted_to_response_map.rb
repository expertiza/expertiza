class AddNotificationAcceptedToResponseMap < ActiveRecord::Migration
  def self.up
    add_column :response_maps, :notification_accepted, :boolean, :default=>false
  end

  def self.down
    remove_column :response_maps, :notification_accepted
  end
end
