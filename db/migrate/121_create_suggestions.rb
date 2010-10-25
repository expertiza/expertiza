class CreateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :suggestions do |t|
     t.column  :id,                 :int
     t.column  :assignment_id,      :int
     t.column  :title,              :text
     t.column  :description,        :text
     t.column  :status,             :string
     t.column  :unityID,            :string
     t.column  :signup_preference,  :string
     t.column  :control,            :int, :default=>0
     t.timestamps
    end
  end

  def self.down
    drop_table :suggestions
  end
end
