class BidScore
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :score, :team_id, :topic_id
  validates_presence_of :name, :team_id, :topic_id

  def initialize(score,teamId,topicId)
    @score = score
    @team_id = teamId
    @topic_id = topicId
  end

  def persisted?
    false
  end
end

