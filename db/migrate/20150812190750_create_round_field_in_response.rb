class CreateRoundFieldInResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :round, :integer
  end
end
