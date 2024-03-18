class AddPreferenceHomeFlagToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :etc_icons_on_homepage, :boolean, default: true
  end

  def self.down
    remove_column :users, :etc_icons_on_homepage
  end
end
