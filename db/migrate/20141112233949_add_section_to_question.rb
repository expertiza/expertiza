class AddSectionToQuestion < ActiveRecord::Migration

    def change
      change_table :questions do |t|
        t.references :sections
      end
    end

end
