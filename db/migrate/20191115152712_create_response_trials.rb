class CreateResponseTrials < ActiveRecord::Migration
  def change
    create_table :response_trials do |t|

      t.timestamps null: false
    end
  end
end
