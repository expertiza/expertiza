<<<<<<< HEAD
class RenameFieldsInAssignments < ActiveRecord::Migration
  def self.up
    begin
      remove_column :assignments, :start_date
    rescue
    end
    add_column :assignments, :days_between_submissions, :integer
  end

  def self.down
  end
=======
class RenameFieldsInAssignments < ActiveRecord::Migration
  def self.up
    begin
      remove_column :assignments, :start_date
    rescue
    end
    add_column :assignments, :days_between_submissions, :integer
  end

  def self.down
  end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end