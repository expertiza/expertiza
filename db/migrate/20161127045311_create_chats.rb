class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|

      t.integer :assignment_team_id, :null => false,:references=>[:teams, :id]

      t.timestamps null: false

    end
  end
end
