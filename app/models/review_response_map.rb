class ReviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'

  # if this assignment uses "varying rubrics" feature, the "used_in_round" field should not be nil
  # so find the round # from response_map, and use that round # to find corresponding questionnaire_id from assignment_questionnaires table
  # otherwise this assignment does not use the "varying rubrics", so in assignment_questionnaires table there should
  # be only 1 questionnaire with type 'ReviewQuestionnaire'.    -Yang
  def questionnaire
    round = self.round
    if round==nil              #for assignment without varying rubrics
      return self.assignment.questionnaires.find_by_type('ReviewQuestionnaire')
    else
      assignment_id = self.assignment.id
      questionnaire_id= AssignmentQuestionnaire.find_by_assignment_id_and_used_in_round(assignment_id,round).questionnaire_id
      return self.assignment.questionnaires.find_by_id(questionnaire_id)
    end
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

  def self.export_fields(options)
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
        existing = ReviewResponseMap.where(reviewee_id: reviewee.id, reviewer_id:  reviewer.id).first
        if existing.nil?
          ReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
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
        team_id = SignedUpTeam.team_id(reviewee.parent_id, reviewee.user_id)
        existing = ReviewResponseMap.where(reviewee_id: team_id, reviewer_id:  reviewer.id).first
        if existing.nil?
          ReviewResponseMap.create(:reviewee_id => team_id, :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
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

  def metareview_response_maps
    responses = Response.where(map_id:self.id)
    metareview_list=Array.new()
    responses.each do |response|
      metareview_response_maps = MetareviewResponseMap.where(reviewed_object_id:response.id)
      metareview_response_maps.each do |metareview_response_map|
        metareview_list<<metareview_response_map
      end
    end
    metareview_list
  end

  # return  the responses for specified round, for varying rubric feature -Yang
  def self.get_assessments_round_for(team,round)
    team_id =team.id
    responses = Array.new
    if team_id
      maps = ResponseMap.where(:reviewee_id => team_id, :type => "ReviewResponseMap", :round => round)
      maps.each{ |map|
        if map.response
          responses << map.response
        end
      }
      responses.sort! {|a,b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    return responses
  end
end
