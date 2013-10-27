class CreateDeadlineTypes < ActiveRecord::Migration
  def self.up
    create_table :deadline_types do |t|
      t.column :name, :string, :limit=>32
    end
    deadline_type = DeadlineType.create(:name=>"submission")
    deadline_type.save
    deadline_type = DeadlineType.create(:name=>"review")
    deadline_type.save
    deadline_type = DeadlineType.create(:name=>"resubmission")
    deadline_type.save
    deadline_type = DeadlineType.create(:name=>"rereview") # this means permission to review a version that has been submitted since the most recent review deadline
    deadline_type.save
    deadline_type = DeadlineType.create(:name=>"review_of_review")
    deadline_type.save
  end

  def self.down
    drop_table :deadline_types
  end
end
