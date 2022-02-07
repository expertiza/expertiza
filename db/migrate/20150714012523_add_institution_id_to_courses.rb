class AddInstitutionIdToCourses < ActiveRecord::Migration
  def self.up
    add_column "courses","institutions_id",:integer, :default => nil
  end

  def self.down
    remove_column "courses","institutions_id"
  end
end
