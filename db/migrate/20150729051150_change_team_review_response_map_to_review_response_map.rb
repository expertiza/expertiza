class ChangeTeamReviewResponseMapToReviewResponseMap < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      update response_maps set type="ReviewResponseMap" where type="TeamReviewResponseMap";
    SQL
  end
end
