class CreateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :suggestions do |t|
     #t.column  :id,                 :int
     t.column  :assignment_id,      :int
     t.column  :title,              :string
     t.column  :description,        :string, :limit=>750
     t.column  :status,             :string
     t.column  :unityID,            :string
     t.column  :signup_preference,  :string
    end
  end

  def self.down
    drop_table :suggestions
  end
end
