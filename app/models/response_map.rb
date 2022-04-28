class ResponseMap < ApplicationRecord
  extend Scoring
  has_many :response, foreign_key: 'map_id', dependent: :destroy, inverse_of: false
  belongs_to :reviewer, class_name: 'Participant', foreign_key: 'reviewer_id', inverse_of: false

  def map_id
    id
  end

  # return latest versions of the responses
  def self.assessments_for(team)
    responses = []
    # stime = Time.now
    if team
      @array_sort = []
      @sort_to = []
      maps = where(reviewee_id: team.id)
      maps.each do |map|
        next if map.response.empty?

        @all_resp = Response.where(map_id: map.map_id).last
        if map.type.eql?('ReviewResponseMap')
          # If its ReviewResponseMap then only consider those response which are submitted.
          @array_sort << @all_resp if @all_resp.is_submitted
        else
          @array_sort << @all_resp
        end
        # sort all versions in descending order and get the latest one.
        # @sort_to=@array_sort.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
        @sort_to = @array_sort.sort # { |m1, m2| (m1.updated_at and m2.updated_at) ? m2.updated_at <=> m1.updated_at : (m1.version_num ? -1 : 1) }
        responses << @sort_to[0] unless @sort_to[0].nil?
        @array_sort.clear
        @sort_to.clear
      end
      responses = responses.sort { |a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end

  def self.comparator(m1, m2)
    if m1.version_num && m2.version_num
      m2.version_num <=> m1.version_num
    elsif m1.version_num
      -1
    else
      1
    end
  end

  # return latest versions of the response given by reviewer
  def self.reviewer_assessments_for(team, reviewer)
    # get_reviewer may return an AssignmentParticipant or an AssignmentTeam
    # map = where(reviewee_id: team.id, reviewer_id: reviewer.get_reviewer.id)
    map = where(reviewee_id: team.id, reviewer_id: reviewer.id)
    Response.where(map_id: map.first.id).sort { |m1, m2| comparator(m1, m2) }.first
  end

  # Placeholder method, override in derived classes if required.
  def get_all_versions
    []
  end

  def delete(_force = nil)
    destroy
  end

  def show_review
    nil
  end

  def show_feedback(_response)
    nil
  end

  # Evaluates whether this response_map was metareviewed by metareviewer
  # @param[in] metareviewer AssignmentParticipant object
  def metareviewed_by?(metareviewer)
    MetareviewResponseMap.where(reviewee_id: reviewer.id, reviewer_id: metareviewer.id, reviewed_object_id: id).count > 0
  end

  # Assigns a metareviewer to this review (response)
  # @param[in] metareviewer AssignmentParticipant object
  def assign_metareviewer(metareviewer)
    MetareviewResponseMap.create(reviewed_object_id: id,
                                 reviewer_id: metareviewer.id, reviewee_id: reviewer.id)
  end

  def survey?
    false
  end

  def find_team_member
    # ACS Have metareviews done for all teams
    if type.to_s == 'MetareviewResponseMap'
      # review_mapping = ResponseMap.find_by(id: map.reviewed_object_id)
      review_mapping = ResponseMap.find_by(id: reviewed_object_id)
      team = AssignmentTeam.find_by(id: review_mapping.reviewee_id)
    else
      team = AssignmentTeam.find(reviewee_id)
    end
    team
  end

  # Creates new mapping between participants as reviewers and teams as reviewees
  # Mapping coppied from an old assignment teams/participants
  # TODO - rewrite this method, come up with a more meaningful name
  def self.mapreviewresponseparticipant(old_assign, new_assign_id, dict)
    old_assignmentnumber = Assignment.find_by(id: old_assign.id)
    new_assignmentnumber = Assignment.find_by(id: new_assign_id)
    find_participant = Participant.find_by(parent_id: old_assign.id, user_id: @old_assignmentnumber.instructor_id)
    new_participant = @find_participant.dup
    new_participant.parent_id = new_assign_id
    new_participant.save # we should check if this is successful before proceeding
    getnewparticipant = Participant.find_by(parent_id: new_assign_id, user_id: @old_assignmentnumber.instructor_id)
    old_reviewrespmap = ReviewResponseMap.where(reviewed_object_id: old_assign.id)
    old_reviewrespmap.each do |satt|
      if dict.key?(satt.reviewee_id)
        new_reviewrespmap = ReviewResponseMap.new
        new_reviewrespmap.reviewed_object_id = new_assign_id
        new_reviewrespmap.reviewer_id = @getnewparticipant.id
        new_reviewrespmap.reviewee_id = dict[satt.reviewee_id]
        new_reviewrespmap.type = satt.type
        new_reviewrespmap.created_at = satt.created_at
        new_reviewrespmap.calibrate_to = satt.calibrate_to
        new_reviewrespmap.save
      else
        next
      end
    end
  end

end
