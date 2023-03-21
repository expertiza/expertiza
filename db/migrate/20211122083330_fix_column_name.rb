class FixColumnName < ActiveRecord::Migration[4.2]
  def change
    rename_column :duties, :max_duty_limit, :max_members_for_role
  end
end
