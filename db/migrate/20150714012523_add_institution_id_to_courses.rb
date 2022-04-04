class AddInstitutionIdToCourses < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'courses', 'institutions_id', :integer, default: nil
  end

  def self.down
    remove_column 'courses', 'institutions_id'
  end
end
