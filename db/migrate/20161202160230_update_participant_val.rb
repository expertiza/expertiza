class UpdateParticipantVal < ActiveRecord::Migration
  def change
    Participant.update_all(reviewsetting: 0)
   end
end
