class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :duties, :max_duty_limit, :max_members_for_role
  end
end
