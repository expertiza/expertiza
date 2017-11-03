class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.belongs_to :team, :index => true
      t.belongs_to :assignment, :index => true
      t.integer :source, :null => false
      t.string :remote_id, :null => false
      t.string :uri, :null => false

      t.timestamps null: false

      t.index [:remote_id, :uri], unique: true
    end
  end
end
