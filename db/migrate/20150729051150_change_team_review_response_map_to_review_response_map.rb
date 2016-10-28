class ChangeTeamReviewResponseMapToReviewResponseMap < ActiveRecord::Migration
  def change
    execute <<-SQL
      update response_maps set type="ReviewResponseMap" where type="TeamReviewResponseMap";
    SQL
  end
end
