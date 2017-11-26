class ChangeNameInResponseMap < ActiveRecord::Migration
  def change
    rename_column :response_maps , :calibrate_to , :expert_review_to
  end
end
