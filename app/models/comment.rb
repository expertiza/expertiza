# == Schema Information
#
# Table name: comments
#
#  id             :integer          not null, primary key
#  participant_id :integer          default(0), not null
#  private        :boolean          default(FALSE), not null
#  comment        :text             default(""), not null
#

class Comment < ActiveRecord::Base
  belongs_to :participant
end
