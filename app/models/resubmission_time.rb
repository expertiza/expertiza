# == Schema Information
#
# Table name: resubmission_times
#
#  id             :integer          not null, primary key
#  participant_id :integer
#  resubmitted_at :datetime
#

class ResubmissionTime < ActiveRecord::Base
end
