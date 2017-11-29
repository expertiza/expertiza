class AddIntroductionToRequestedUser < ActiveRecord::Migration
  def change
    add_column :requested_users, :introduction, :text
  end
end
