class FixColumnName2 < ActiveRecord::Migration[4.2]
  def change
    rename_column :duties, :max_members_for_role, :max_members_for_duty
  end
end
