class AddIdToExpiryLinks < ActiveRecord::Migration
  def change
    add_column :expiry_links, :uid, :integer
  end
end
