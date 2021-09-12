class ResponseMap < ActiveRecord::Base
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
  def self.reviewer_assessments_for(team, reviewer)
    # get_reviewer may return an AssignmentParticipant or an AssignmentTeam
    map = where(reviewee_id: team.id, reviewer_id: reviewer.get_reviewer.id)
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
  
  def find_team_member
    # ACS Have metareviews done for all teams
    if self.type.to_s == "MetareviewResponseMap"
        review_mapping = ResponseMap.find_by(id: map.reviewed_object_id)
        team = AssignmentTeam.find_by(id: review_mapping.reviewee_id)
    else
        team = AssignmentTeam.find(self.reviewee_id)
    end
  end

  #Computes and returns the scores of assignment for participants and teams
  def self.scores(assignment, questions)
    scores = {:participants => {}, :teams => {}}
    assignment.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant.scores(questions)
    end
    index = 0
    assignment.teams.each do |team|
      scores[:teams][index.to_s.to_sym] = {:team => team, :scores => {}}
      if assignment.vary_by_round
        grades_by_rounds, total_num_of_assessments, total_score = compute_grades_by_rounds(assignment, questions, team)
        # merge the grades from multiple rounds
        scores[:teams][index.to_s.to_sym][:scores] = merge_grades_by_rounds(assignment, grades_by_rounds, total_num_of_assessments, total_score)
      else
        assessments = ReviewResponseMap.assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Response.compute_scores(assessments, questions[:review])
      end
      index += 1
    end
    scores
  end

  private
  #Below private methods are extracted and added as part of refactoring project E2009 - Spring 2020
  #This method computes and returns grades by rounds, total_num_of_assessments and total_score
  # when the assignment has varying rubrics by round
  def self.compute_grades_by_rounds(assignment, questions, team)
    grades_by_rounds = {}
    total_score = 0
    total_num_of_assessments = 0 # calculate grades for each rounds
    (1..assignment.num_review_rounds).each do |i|
      assessments = ReviewResponseMap.get_responses_for_team_round(team, i)
      round_sym = ("review" + i.to_s).to_sym
      grades_by_rounds[round_sym] = Response.compute_scores(assessments, questions[round_sym])
      total_num_of_assessments += assessments.size
      total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f unless grades_by_rounds[round_sym][:avg].nil?
    end
    return grades_by_rounds, total_num_of_assessments, total_score
  end

  # merge the grades from multiple rounds
  def self.merge_grades_by_rounds(assignment, grades_by_rounds, num_of_assessments, total_score)
    team_scores = {:max => 0, :min => 0, :avg => nil}
    if num_of_assessments.zero?
      return team_scores
    end
    team_scores[:max] = -999_999_999
    team_scores[:min] = 999_999_999
    team_scores[:avg] = total_score / num_of_assessments
    (1..assignment.num_review_rounds).each do |i|
      round_sym = ("review" + i.to_s).to_sym
      unless grades_by_rounds[round_sym][:max].nil? || team_scores[:max] >= grades_by_rounds[round_sym][:max]
        team_scores[:max] = grades_by_rounds[round_sym][:max]
      end
      unless grades_by_rounds[round_sym][:min].nil? || team_scores[:min] <= grades_by_rounds[round_sym][:min]
        team_scores[:min] = grades_by_rounds[round_sym][:min]
      end
    end
    team_scores
  end
end
