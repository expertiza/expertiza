class Bid < ActiveRecord::Base
  belongs_to :sign_up_topic
  belongs_to :team
  attr_accessible :topic_id, :team_id

  # Create a bid for a team and topic
  def create

     # Should get a team_id and sign_up_topic_id as parameters
    puts "create new bid for team #{self.team_id} and topic #{self.topic_id}"
  end

  # Delete a bid for a team and topic
  def destroy
    # Should get a team_id and sign_up_topic_id as parameters
  end
end
