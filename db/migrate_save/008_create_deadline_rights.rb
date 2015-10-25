class CreateDeadlineRights < ActiveRecord::Migration
  def self.up
    create_table :deadline_rights do |t|
      t.column :name, :string, :limit=>32
    end
    deadline_right = DeadlineRight.create(:name=>"No")
    deadline_right.save
    deadline_right = DeadlineRight.create(:name=>"Late")
    deadline_right.save
    deadline_right = DeadlineRight.create(:name=>"OK")
    deadline_right.save
  end

  def self.down
    drop_table :deadline_rights
  end
end
