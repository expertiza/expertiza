class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant

  def notify_student
  	pariticpant = Participant.find_by_id(self.participant_id)
  	#send student email to upload evidence
  end

  def is_approved?
    self.approval_status == 1
  end
end
