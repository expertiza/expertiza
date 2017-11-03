class AddQuizAllowedIdToDueDates < ActiveRecord::Migration
  def self.up
    add_column :due_dates, :quiz_allowed_id, :integer
  end

  def self.down
    delete_column :due_dates, :quiz_allowed_id
  end

end
