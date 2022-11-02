# frozen_string_literal: true

class DropisSubmittedFieldFromResponseMaps < ActiveRecord::Migration[4.2]
  def change
    remove_column 'response_maps', 'isSubmitted'
  end
end
