class AddPrivateFieldToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :private, :tinyint
  end
end
