class DropisSubmittedFieldFromResponseMaps < ActiveRecord::Migration
  def change
    remove_column "response_maps","isSubmitted"
  end
end
