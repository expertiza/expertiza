<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
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
<<<<<<< HEAD
=======
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
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
end