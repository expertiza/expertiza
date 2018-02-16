class MetareviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :review_mapping, class_name: 'ResponseMap', foreign_key: 'reviewed_object_id'
  delegate :assignment, to: :reviewee

  # return all the versions available for a response map.
  # a person who is doing meta review has to be able to see all the versions of review.
  def get_all_versions
    if self.review_mapping.response
      @sorted_array = []
      @prev = Response.all
      @prev.each do |element|
        @sorted_array << element if element.map_id == self.review_mapping.map_id
      end
      @sorted = @sorted_array.sort {|m1, m2| m1.version_num and m2.version_num ? m1.version_num <=> m2.version_num : (m1.version_num ? -1 : 1) }
      # return all the lists in ascending order.
      @sorted
    else
      nil # "<I>No review was performed.</I><br/><hr/><br/>"
    end
  end

  # First, find the "ReviewResponseMap" to be metareviewed;
  # Second, find the team in the "ReviewResponseMap" record.
  def contributor
    team_review_map = ReviewResponseMap.find(self.reviewed_object_id)
    AssignmentTeam.find(team_review_map.reviewee_id)
  end

  def questionnaire
    self.assignment.questionnaires.find_by(type: 'MetareviewQuestionnaire')
  end

  def get_title
    "Metareview"
  end

  def self.export(csv, parent_id, _options)
    mappings = Assignment.find(parent_id).metareview_mappings
    mappings = mappings.sort_by {|a| [a.review_mapping.reviewee.name, a.reviewee.name, a.reviewer.name] }
    mappings.each do |map|
      csv << [
        map.review_mapping.reviewee.name,
        map.reviewee.name,
        map.reviewer.name
      ]
    end
  end

  def self.export_fields(_options)
    fields = ["contributor", "reviewed by", "metareviewed by"]
    fields
  end

  def self.import(row_hash, session, id)
    raise ArgumentError.new("Not enough items. The string should contain: Author, Reviewer, ReviewOfReviewer1 <, ..., ReviewerOfReviewerN>") if row_hash.length < 3
    row_hash[:metareviewers].each do |row|
      # ACS Make All contributors as teams
      contributor = AssignmentTeam.where(name: row_hash[:reviewee].to_s, parent_id:  id).first
      raise ImportError, "Contributor, " + row_hash[:reviewee].to_s + ", was not found."  if contributor.nil?
      ruser = User.find_by_name(row_hash[:reviewer].to_s.strip)
      reviewee = AssignmentParticipant.where(user_id: ruser.id, parent_id:  id).first
      raise ImportError, "Reviewee,  #{row_hash[:reviewer].to_s}, for contributor, #{contributor.name}, was not found." if reviewee.nil?
      muser = User.find_by_name(row.to_s.strip)
      reviewer = AssignmentParticipant.where(user_id: muser.id, parent_id:  id).first
      raise ImportError, "Metareviewer,  #{row.to_s}, for contributor, #{contributor.name}, and reviewee, #{row_hash[:reviewer].to_s }, was not found." if reviewer.nil?
      # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
      # to treat all assignments as team assignments
      reviewmapping = ReviewResponseMap.where(reviewee_id: contributor.id, reviewer_id:  reviewee.id).first
      raise ImportError, "No review mapping was found for contributor, #{contributor.name}, and reviewee, #{row_hash[:reviewer].to_s}." if reviewmapping.nil?
      existing_mappings = MetareviewResponseMap.where(reviewee_id: reviewee.id, reviewer_id: reviewer.id, reviewed_object_id: reviewmapping.map_id)
      # if no mappings have already been imported for this combination
      # create it.
      MetareviewResponseMap.create(reviewer_id: reviewer.id, reviewee_id: reviewee.id, reviewed_object_id: reviewmapping.map_id) if existing_mappings.empty?
    end
  end

  def email(defn, _participant, assignment)
    defn[:body][:type] = "Metareview"
    reviewee_user = Participant.find(reviewee_id)
    defn[:body][:obj_name] = assignment.name
    defn[:body][:first_name] = User.find(reviewee_user.user_id).fullname
    defn[:to] = User.find(reviewee_user.user_id).email
    Mailer.sync_message(defn).deliver
  end
end
