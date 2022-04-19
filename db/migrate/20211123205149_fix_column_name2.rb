class FixColumnName2 < ActiveRecord::Migration
  def change
    rename_column :duties, :max_members_for_role, :max_members_for_duty
  end
end
