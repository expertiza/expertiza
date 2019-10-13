class ResponseMap < ActiveRecord::Base
  has_many :response, foreign_key: 'map_id', dependent: :destroy, inverse_of: false
  belongs_to :reviewer, class_name: 'Participant', foreign_key: 'reviewer_id', inverse_of: false

  def map_id
    id
  end

  # return latest versions of the responses
  def self.get_assessments_for(team)
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
      responses = responses.sort {|a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end

  def comparator(m1, m2)
    if m1.version_num and m2.version_num
      m2.version_num <=> m1.version_num
    elsif m1.version_num
      -1
    else
      1
    end
  end

  # return latest versions of the response given by reviewer
  def self.get_reviewer_assessments_for(team, reviewer)
    map = where(reviewee_id: team.id, reviewer_id: reviewer.id)
    Response.where(map_id: map).sort {|m1, m2| self.comparator(m1, m2) }[0]
  end

  # Placeholder method, override in derived classes if required.
  def get_all_versions
    []
  end

  def delete(_force = nil)
    self.destroy
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
    MetareviewResponseMap.where(reviewee_id: self.reviewer.id, reviewer_id: metareviewer.id, reviewed_object_id: self.id).count > 0
  end

  # Assigns a metareviewer to this review (response)
  # @param[in] metareviewer AssignmentParticipant object
  def assign_metareviewer(metareviewer)
    MetareviewResponseMap.create(reviewed_object_id: self.id,
                                 reviewer_id: metareviewer.id, reviewee_id: reviewer.id)
  end

  def survey?
    false
  end
end
