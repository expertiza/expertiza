# frozen_string_literal: true

class AddNumReviewsToAssignments < ActiveRecord::Migration[4.2]
  def change
    change_column :assignments, :num_reviews, :integer, default: 3
  end
end
