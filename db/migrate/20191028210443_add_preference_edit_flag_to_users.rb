class AddPreferenceEditFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preference_edit_flag, :boolean , :default => true
  end
end
