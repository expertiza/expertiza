class MetareviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :review_mapping, class_name: 'ResponseMap', foreign_key: 'reviewed_object_id'
  delegate :assignment, to: :reviewee

  # return all the versions available for a response map.
  # a person who is doing meta review has to be able to see all the versions of review.
  def get_all_versions
    if review_mapping.response
      @sorted_array = []
      @prev = Response.all
      @prev.each do |element|
        @sorted_array << element if element.map_id == review_mapping.map_id
      end
      @sorted = @sorted_array.sort do |m1, m2|
        m1.version_num || if m2.version_num
                            m1.version_num <=> m2.version_num
                          else
                            m1.version_num ? -1 : 1
                          end
      end
      # return all the lists in ascending order.
      @sorted
    end
  end

  # First, find the "ReviewResponseMap" to be metareviewed;
  # Second, find the team in the "ReviewResponseMap" record.
  def contributor
    team_review_map = ReviewResponseMap.find(reviewed_object_id)
    AssignmentTeam.find(team_review_map.reviewee_id)
  end

  def questionnaire
    assignment.questionnaires.find_by(type: 'MetareviewQuestionnaire') # filter for MetaReview Questionnaire
  end

  def get_title
    'Metareview'
  end

  def self.export(csv, parent_id, _options)
    mappings = Assignment.find(parent_id).metareview_mappings
    mappings = mappings.sort_by { |a| [a.review_mapping.reviewee.name, a.reviewee.name, a.reviewer.name] }
    mappings.each do |map|
      csv << [
        map.review_mapping.reviewee.name,
        map.reviewee.name,
        map.reviewer.name
      ]
    end
  end

  def self.export_fields(_options)
    fields = ['contributor', 'reviewed by', 'metareviewed by']
    fields
  end

  def self.import(row_hash, _session = nil, id)
    raise ArgumentError, 'Record does not contain required items.' if row_hash.length < required_import_fields.length
    row_hash[:metareviewers].split.each do |row|
      team_reviewed = AssignmentTeam.where(name: row_hash[:team_name].to_s, parent_id: id).first
      raise ImportError, 'Reviewee team, ' + row_hash[:team_name].to_s + ', was not found.' if team_reviewed.nil?
      ruser = User.find_by_name(row_hash[:reviewer].to_s.strip)
      raise ImportError, "Reviewer #{row_hash[:reviewer]} not found." if ruser.nil?
      reviewer = AssignmentParticipant.where(user_id: ruser.id, parent_id: id).first
      raise ImportError, "Reviewer,  #{row_hash[:reviewer]}, for reviewee team, #{team_reviewed.name}, was not found." if reviewer.nil?
      muser = User.find_by_name(row.to_s.strip)
      raise ImportError, "Metareviewer #{row} not found." if muser.nil?
      metareviewer = AssignmentParticipant.where(user_id: muser.id, parent_id: id).first
      raise ImportError, "Metareviewer,  #{row}, for reviewee, #{team_reviewed.name}, and reviewer, #{row_hash[:reviewer]}, was not found." if metareviewer.nil?
      reviewmapping = ReviewResponseMap.where(reviewee_id: team_reviewed.id, reviewer_id:  reviewer.id).first
      raise ImportError, "No review mapping was found for reviewee team, #{team_reviewed.name}, and reviewer, #{row_hash[:reviewer]}." if reviewmapping.nil?
      existing_mappings = MetareviewResponseMap.where(reviewee_id: reviewer.id, reviewer_id: metareviewer.id, reviewed_object_id: reviewmapping.map_id)
      MetareviewResponseMap.create(reviewer_id: metareviewer.id, reviewee_id: reviewer.id, reviewed_object_id: reviewmapping.map_id) if existing_mappings.empty?
    end
  end

  def self.required_import_fields
    { 'team_name' => 'Reviewed Team',
      'reviewer' => 'Reviewer',
      'metareviewers' => 'Metareviewer List' }
  end

  def self.optional_import_fields(_id = nil)
    {}
  end

  def self.import_options
    {}
  end

  def email(defn, _participant, assignment)
    defn[:body][:type] = 'Metareview'
    reviewee_user = Participant.find(reviewee_id)
    defn[:body][:obj_name] = assignment.name
    defn[:body][:first_name] = User.find(reviewee_user.user_id).fullname
    defn[:to] = User.find(reviewee_user.user_id).email
    Mailer.sync_message(defn).deliver
  end
end
