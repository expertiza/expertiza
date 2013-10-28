class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.column :name, :string, :limit=>32
    end
  end

  def self.down
    drop_table :languages
  end
end
