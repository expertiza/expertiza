class AddIsConferenceToAssginment < ActiveRecord::Migration
  def change
		add_column :assignments, :is_conference?, :boolean , default: false
  end
end
