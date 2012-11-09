class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.belongs_to :topic
      t.belongs_to :team
    end
  end

  def self.down
    drop_table :bids
  end
end
