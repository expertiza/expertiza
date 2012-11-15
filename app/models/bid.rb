class Bid < ActiveRecord::Base
  belongs_to :sign_up_topic
  belongs_to :team

  # Create a bid for a team and topic
  def create(team_id, topic_id)
    @bid = Bid.new
    @bid.team_id = team_id
    @bid.topic_id = topic_id
    @bid.save

     # Should get a team_id and sign_up_topic_id as parameters
    puts "create new bid for team #{@bid.team_id} and topic #{@bid.topic_id}"
  end

  # Delete a bid for a team and topic
  def destroy
    # Should get a team_id and sign_up_topic_id as parameters
  end
end
