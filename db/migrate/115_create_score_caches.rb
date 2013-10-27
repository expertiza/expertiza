class CreateScoreCaches < ActiveRecord::Migration
  def self.up
    create_table :score_caches do |t|
          t.column "object_id", :integer, :default => 0, :null => false          
          t.column "assignment_id", :integer, :default => 0, :null => true
          t.column "course_id", :integer, :default => 0, :null => true
          t.column "score", :float, :default => 0, :null => false
          t.column "range", :string, :default => ""         
          t.column "object_type", :string, :null =>false
          
      


    end
  end

  def self.down
    drop_table :score_caches
  end
end
