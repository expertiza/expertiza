class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  has_many :bookmark_ratings
  validates :url, presence: true
  validates :title, presence: true
  validates :description, presence: true

  # Computes the average rating when the ratings are provided via rubrics
  def average_based_on_rubric
    assignment = SignUpTopic.find(topic_id).assignment
    questions = assignment.questionnaires.where(type: 'BookmarkRatingQuestionnaire').flat_map(&:questions)
    responses = BookmarkRatingResponseMap.where(
      reviewed_object_id: assignment.id,
      reviewee_id: id
    ).flat_map {|r| Response.where(map_id: r.id) }
    scores = Answer.compute_scores(responses, questions)
    if scores[:avg].nil?
      0
    else
      (scores[:avg] * 5.0 / 100.0).round(2)
    end
  end
end
