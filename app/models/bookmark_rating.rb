class BookmarkRating < ActiveRecord::Base
  belongs_to :bookmark
  belongs_to :user

  def self.average_based_on_rubric(bookmark)
    if bookmark.nil?
      0
    else
      assignment = SignUpTopic.find(bookmark.topic_id).assignment
      questions = assignment.questionnaires.where(type: 'BookmarkRatingQuestionnaire').flat_map(&:questions)
      responses = BookmarkRatingResponseMap.where(
        reviewed_object_id: assignment.id,
        reviewee_id: bookmark.id
      ).flat_map {|r| Response.where(map_id: r.id) }
      scores = Answer.compute_scores(responses, questions)
      if scores[:avg].nil?
        0
      else
        (scores[:avg] * 5.0 / 100.0).round(2)
      end
    end
  end

  def self.get_bookmark_rating_response_map(bookmark, current_user)
    BookmarkRatingResponseMap.find_by(
      reviewed_object_id: SignUpTopic.find(bookmark.topic_id).assignment.id,
      reviewer_id: AssignmentParticipant.find_by(user_id: current_user.id).id,
      reviewee_id: bookmark.id
    )
  end
end
