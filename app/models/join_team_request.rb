# == Schema Information
#
# Table name: join_team_requests
#
#  id             :integer          not null, primary key
#  participant_id :integer
#  team_id        :integer
#  comments       :text
#  status         :string(1)
#  created_at     :datetime
#  updated_at     :datetime
#

class JoinTeamRequest < ActiveRecord::Base
 belongs_to :team
 has_one :participant
end
