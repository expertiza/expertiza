class AddPreferenceHomeFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preference_home_flag, :boolean , :default => true
  end
end
