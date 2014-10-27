# == Schema Information
#
# Table name: response_maps
#
#  id                    :integer          not null, primary key
#  reviewed_object_id    :integer          default(0), not null
#  reviewer_id           :integer          default(0), not null
#  reviewee_id           :integer          default(0), not null
#  type                  :string(255)      default(""), not null
#  notification_accepted :boolean          default(FALSE)
#  round                 :integer
#

class ParticipantReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id'

end
