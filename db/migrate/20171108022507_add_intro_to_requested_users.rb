class AddIntroToRequestedUsers < ActiveRecord::Migration
  def change
    add_column :requested_users, :intro, :string
  end
end
