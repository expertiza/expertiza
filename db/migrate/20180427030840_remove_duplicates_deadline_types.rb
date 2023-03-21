class RemoveDuplicatesDeadlineTypes < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      update due_dates set deadline_type_id=7 where deadline_type_id=9
    SQL

    execute <<-SQL
      delete from deadline_types where id=9
    SQL
  end

  def down; end
end
