class Bid < ActiveRecord::Base
  belongs_to :sign_up_topic
  belongs_to :team

  # Create a bid for a team and topic
  def create
     # Should get a team_id and sign_up_topic_id as parameters
  end

  # Delete a bid for a team and topic
  def destroy
    # Should get a team_id and sign_up_topic_id as parameters
  end
end
