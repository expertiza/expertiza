class CreateDuties < ActiveRecord::Migration
  def change
    create_table :duties do |t|
      t.string :duty_name ,  :null => false ,:unique => true
      t.boolean :multiple_duty ,:default => false

    end
  end
end
