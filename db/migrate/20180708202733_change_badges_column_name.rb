class ChangeBadgesColumnName < ActiveRecord::Migration
  def change
	rename_column :badges, :image_name, :image_url
  end
end
