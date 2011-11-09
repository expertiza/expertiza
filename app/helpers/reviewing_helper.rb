module ReviewingHelper

  # Returns a set of topics that can be reviewed.
  # We choose the topics if one of its submissions has received the fewest reviews so far
  def candidate_topics_to_review
    return nil if sign_up_topics.empty?   # This is not a topic assignment

    contributor_set = Array.new(contributors)

    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set.reject! { |contributor| signed_up_topic(contributor).nil? or !contributor.has_submissions? }

    # Reject contributions of topics whose deadline has passed
    contributor_set.reject! { |contributor| contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "Complete" or
                                            contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "submission" }
    # Filter the contributors with the least number of reviews
    # (using the fact that each contributor is associated with a topic)
    contributor = contributor_set.min_by { |contributor| contributor.review_mappings.count }

    min_reviews = contributor.review_mappings.count rescue 0
    contributor_set.reject! { |contributor| contributor.review_mappings.count > min_reviews + review_topic_threshold }

    candidate_topics = Set.new
    contributor_set.each { |contributor| candidate_topics.add(signed_up_topic(contributor)) }
    candidate_topics
  end

   # Returns a contributor to review if available, otherwise will raise an error
  def contributor_to_review(reviewer, topic)
    raise "Please select a topic" if has_topics? and topic.nil?
    raise "This assignment does not have topics" if !has_topics? and topic

    # This condition might happen if the reviewer waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    if topic
      raise "This topic has too many reviews; please select another one." unless candidate_topics_to_review.include?(topic)
    end

    contributor_set = Array.new(contributors)
    work = (topic.nil?) ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor|
      signed_up_topic(contributor) != topic or # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) or
        !contributor.has_submissions?
    end
    raise "There are no more submissions to review on this #{work}." if contributor_set.empty?

    # Reviewer can review each contributor only once
    contributor_set.reject! { |contributor| contributor.reviewed_by?(reviewer) }
    raise "You have already reviewed all submissions for this #{work}." if contributor_set.empty?

    # Reduce to the contributors with the least number of reviews ("responses") received
    min_contributor = contributor_set.min_by { |a| a.responses.count }
    min_reviews = min_contributor.responses.count
    contributor_set.reject! { |contributor| contributor.responses.count > min_reviews }

    # Pick the contributor whose most recent reviewer was assigned longest ago
    if min_reviews > 0
      # Sort by last review mapping id, since it reflects the order in which reviews were assigned
      # This has a round-robin effect
      # Sorting on id assumes that ids are assigned sequentially in the db.
      # .last assumes the database returns rows in the order they were created.
      # Added unit tests to ensure these conditions are both true with the current database.
      contributor_set.sort! { |a, b| a.review_mappings.last.id <=> b.review_mappings.last.id }
  end

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    return contributor_set.sample
  end




   # Returns a review (response) to metareview if available, otherwise will raise an error
  def response_map_to_metareview(metareviewer)
    response_map_set = Array.new(review_mappings)

    # Reject response maps without responses
    response_map_set.reject! { |response_map| !response_map.response }
    raise "There are no reviews to metareview at this time for this assignment." if response_map_set.empty?

    # Reject reviews where the metareviewer was the reviewer or the contributor
    response_map_set.reject! do |response_map|
      (response_map.reviewee == metareviewer) or (response_map.reviewer.includes?(metareviewer))
    end
    raise "There are no more reviews to metareview for this assignment." if response_map_set.empty?

    # Metareviewer can only metareview each review once
    response_map_set.reject! { |response_map| response_map.metareviewed_by?(metareviewer) }
    raise "You have already metareviewed all reviews for this assignment." if response_map_set.empty?

    # Reduce to the response maps with the least number of metareviews received
    response_map_set.sort! { |a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    response_map_set.reject! { |response_map| response_map.metareview_response_maps.count > min_metareviews }

    # Reduce the response maps to the reviewers with the least number of metareviews received
    reviewers = Hash.new    # <reviewer, number of metareviews>
    response_map_set.each do |response_map|
      reviewer = response_map.reviewer
      reviewers.member?(reviewer) ? reviewers[reviewer] += 1 : reviewers[reviewer] = 1
    end
    reviewers = reviewers.sort { |a, b| a[1] <=> b[1] }
    min_metareviews = reviewers.first[1]
    reviewers.reject! { |reviewer| reviewer[1] == min_metareviews }
    response_map_set.reject! { |response_map| reviewers.member?(response_map.reviewer) }

    # Pick the response map whose most recent metareviewer was assigned longest ago
    response_map_set.sort! { |a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    if min_metareviews > 0
      # Sort by last metareview mapping id, since it reflects the order in which reviews were assigned
      # This has a round-robin effect
      response_map_set.sort! { |a, b| a.metareview_response_maps.last.id <=> b.metareview_response_maps.last.id }
    end

    # The first review_map is the best candidate to metareview
    return response_map_set.first
  end


  def review_mappings
    @review_mappings ||= team_assignment ? team_review_mappings : participant_review_mappings
  end


  def review_mappings
    if team_assignment
      TeamReviewResponseMap.find_all_by_reviewed_object_id(self.id)
    else
      ParticipantReviewResponseMap.find_all_by_reviewed_object_id(self.id)
    end
  end

  def metareview_mappings
     mappings = Array.new
     self.review_mappings.each{
       | map |
       mmap = MetareviewResponseMap.find_by_reviewed_object_id(map.id)
       if mmap != nil
         mappings << mmap
       end
     }
     return mappings
  end


  # Get all review mappings for this assignment & reviewer
  # required to give reviewer location of new submission content
  # link can not be provided as it might give user ability to access data not
  # available to them.
  #ajbudlon, sept 07, 2007
  def get_review_number(mapping)
    reviewer_mappings = ResponseMap.find_all_by_reviewer_id(mapping.reviewer.id)
    review_num = 1
    for rm in reviewer_mappings
      if rm.reviewee.id != mapping.reviewee.id
        review_num += 1
      else
        break
      end
    end
    return review_num
  end



  # Generate emails for reviewers when new content is available for review
  #ajbudlon, sept 07, 2007
  def email(author_id)

    # Get all review mappings for this assignment & author
    participant = AssignmentParticipant.find(author_id)
    if team_assignment
      author = participant.team
    else
      author = participant
    end

    for mapping in author.review_mappings

       # If the reviewer has requested an e-mail deliver a notification
       # that includes the assignment, and which item has been updated.
       if mapping.reviewer.user.email_on_submission
          user = mapping.reviewer.user
          Mailer.deliver_message(
            {:recipients => user.email,
             :subject => "A new submission is available for #{self.name}",
             :body => {
              :obj_name => self.name,
              :type => "submission",
              :location => get_review_number(mapping).to_s,
              :first_name => ApplicationHelper::get_user_first_name(user),
              :partial_name => "update"
             }
            }
          )
       end
    end
  end


   def get_review_rounds
    due_dates = DueDate.find_all_by_assignment_id(self.id)
    rounds = 0
    for i in (0 .. due_dates.length-1)
      deadline_type = DeadlineType.find(due_dates[i].deadline_type_id)
      if deadline_type.name == "review" || deadline_type.name == "rereview"
        rounds = rounds + 1
      end
    end
    rounds
  end


end
