class AlterUserIdInBidsTableToTeamId < ActiveRecord::Migration
  def change
    Bid.all.each do |bid|
      begin
        topic_id = bid.topic_id
        user_id = bid.user_id
        team_id = SignUpTopic.find_by(id: topic_id).assignment.teams.
          select{ |t| t.users.map(&:id).include?(user_id) }.first.id
        bid.user_id = team_id
        bid.save
      rescue => e
      end
    end
    rename_column :bids, :user_id, :team_id
  end
end
