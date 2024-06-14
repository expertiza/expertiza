module QuizAssignment
  # Returns a set of topics that can be used for taking the quiz.
  # We choose the topics if one of its quiz submissions has been attempted the fewest times so far
  def candidate_topics_for_quiz
    return nil if sign_up_topics.empty? # This is not a topic assignment

    contributor_set = Array.new(contributors)
    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set.reject! { |contributor| signed_up_topic(contributor).nil? }

    # Reject contributions of topics whose deadline has passed
    contributor_set.reject! do |contributor|
      (contributor.assignment.current_stage(signed_up_topic(contributor).id) == 'Complete') ||
        (contributor.assignment.current_stage(signed_up_topic(contributor).id) == 'submission')
    end

    candidate_topics = Set.new
    contributor_set.each { |contributor| candidate_topics.add(signed_up_topic(contributor)) }
    candidate_topics
  end

  # Returns a contributor whose quiz is to be taken if available, otherwise will raise an error
  def contributor_for_quiz(reviewer, topic)
    raise 'Please select a topic.' if topics? && topic.nil?
    raise 'This assignment does not have topics.' unless topics? || !topic

    # This condition might happen if the reviewer/quiz taker waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    if topic
      raise 'Too many quizzes have been taken for this topic; please select another one.' unless candidate_topics_for_quiz.include?(topic)
    end

    contributor_set = Array.new(contributors)
    work = topic.nil? ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer/quiz taker as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor|
      (signed_up_topic(contributor) != topic) || # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) # ##or !contributor.has_quiz?
    end
    raise "There are no more submissions to take quiz on for this #{work}." if contributor_set.empty?

    # Reviewer/quiz taker can take quiz for each submission only once
    contributor_set.reject! { |contributor| quiz_taken_by?(contributor, reviewer) }
    # raise "You have already taken the quiz for all submissions for this #{work}." if contributor_set.empty?

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    contributor_set.sample
  end

  def quiz_taken_by?(contributor, reviewer)
    quiz_id = QuizQuestionnaire.find_by(instructor_id: contributor.id).id
    QuizResponseMap.where('reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ?',
                          contributor.id, reviewer.id, quiz_id).count > 0
  end
end
