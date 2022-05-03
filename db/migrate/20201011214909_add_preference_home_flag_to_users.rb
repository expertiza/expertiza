class AddPreferenceHomeFlagToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :preference_home_flag, :boolean, default: true
  end

  def self.down
    remove_column :users, :preference_home_flag
  end
end
