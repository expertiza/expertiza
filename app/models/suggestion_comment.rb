# == Schema Information
#
# Table name: suggestion_comments
#
#  id            :integer          not null, primary key
#  comments      :text
#  commenter     :string(255)
#  vote          :string(255)
#  suggestion_id :integer
#  created_at    :datetime
#

class SuggestionComment < ActiveRecord::Base
  validates_presence_of :comments
  belongs_to :suggestion
end
