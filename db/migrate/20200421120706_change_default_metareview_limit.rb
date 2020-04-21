class ChangeDefaultMetareviewLimit < ActiveRecord::Migration
  def change
	change_column_default :assignments, :num_metareviews_required, from: 3, to: nil
	change_column_default :assignments, :num_metareviews_allowed, from: 3, to: nil
  end
end