class AddNotificationNotSentToResponseMap < ActiveRecord::Migration
  def self.up
    add_column :response_maps, :notification_not_sent, :boolean, :default=>true
  end

  def self.down
    remove_column :response_maps, :notification_not_sent
  end
end
