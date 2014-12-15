class ReviewResponseMap < ResponseMap
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'

  def questionnaire
    self.assignment.questionnaires.find_by_type('ReviewQuestionnaire')
  end

  def get_title
    return "Review"
  end

  def delete(force = nil)
    fmaps = FeedbackResponseMap.where(reviewed_object_id: self.response.response_id)
    fmaps.each { |fmap| fmap.delete(true) }
    maps = MetareviewResponseMap.where(reviewed_object_id: self.id)
    maps.each { |map| map.delete(force) }
    self.destroy
  end

  def self.get_export_fields(options)
    fields = ["contributor", "reviewed by"]
    return fields
  end

  def self.export(csv, parent_id, options)
    mappings = where(reviewed_object_id: parent_id)
    mappings.sort! { |a, b| a.reviewee.name <=> b.reviewee.name }
    mappings.each {
      |map|
      csv << [
        map.reviewee.name,
        map.reviewer.name
      ]
    }
  end

  def self.import(row, session, id)
    if row.length < 2
      raise ArgumentError, "Not enough items"
    end

    assignment = Assignment.find(id)
    if assignment.nil?
      raise ImportError, "The assignment with id \"#{id}\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    index = 1
    while index < row.length
      user = User.find_by_name(row[index].to_s.strip)
      if user.nil?
        raise ImportError, "The user account for the reviewer \"#{row[index]}\" was not found. <a href='/users/new'>Create</a> this user?"
      end
      reviewer = AssignmentParticipant.where(user_id: user.id, parent_id:  assignment.id).first
      if reviewer == nil
        raise ImportError, "The reviewer \"#{row[index]}\" is not a participant in this assignment. <a href='/users/new'>Register</a> this user as a participant?"
      end
      if assignment.team_assignment
        reviewee = AssignmentTeam.where(name: row[0].to_s.strip, parent_id:  assignment.id).first
        if reviewee == nil
          raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"
        end
        existing = TeamReviewResponseMap.where(reviewee_id: reviewee.id, reviewer_id:  reviewer.id).first
        if existing.nil?
          TeamReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
        end
      else
        puser = User.find_by_name(row[0].to_s.strip)
        if user == nil
          raise ImportError, "The user account for the reviewee \"#{row[0]}\" was not found. <a href='/users/new'>Create</a> this user?"
        end
        reviewee = AssignmentParticipant.where(user_id: puser.id, parent_id:  assignment.id).first
        if reviewee == nil
          raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"
        end
        existing = ParticipantReviewResponseMap.where(reviewee_id: reviewee.id, reviewer_id:  reviewer.id).first
        if existing.nil?
          ParticipantReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
        end
      end
      index += 1
    end
  end

  def show_feedback()
    if(self.response)
      map = FeedbackResponseMap.find_by_reviewed_object_id(self.response.response_id)
      if map and map.response
        return map.response.display_as_html()
      end
    end
  end

  # This method adds a new entry in the ResponseMap
  def self.add_reviewer(contributor_id, reviewer_id, assignment_id)
    if where(reviewee_id: contributor_id, reviewer_id: reviewer_id).count > 0
      create(:reviewee_id => contributor_id,
             :reviewer_id => reviewer_id,
             :reviewed_object_id => assignment_id)
    else
      raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
    end
  end

end
