class ChangeIsSubmittedToBoolean < ActiveRecord::Migration
  def change
    remove_column :responses, :isSubmitted
    add_column :responses, :is_submitted, :boolean, default: false
    execute "update responses set is_submitted=1;"
  end
end
