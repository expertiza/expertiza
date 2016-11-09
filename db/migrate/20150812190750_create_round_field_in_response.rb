class CreateRoundFieldInResponse < ActiveRecord::Migration
  def change
    add_column :responses, :round, :integer
  end
end
