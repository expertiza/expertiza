class Reviewsettingdefault < ActiveRecord::Migration
  def up
    change_column_default :participants, :reviewsetting, 0
  end

  def down
    change_column_default :participants, :reviewsetting, nil
  end
end
