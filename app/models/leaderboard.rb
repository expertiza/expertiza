# second change
# Currently this is a repository for a lot of static class methods.
# Many of the methods were moved to leaderboard_helper.rb and more
# probably should be moved.
class Leaderboard < ActiveRecord::Base
  # This module is not really required, but can be helpful when
  # using the script/console and needing to print hash structures.
  require 'pp'

  # This method gets all the assignments associated with a courses
  # in an array. A course_id of 0 will get assignments not affiliated
  # with a specific course.

  ### This methodreturns unaffiliiated assignments - assignments not affiliated to any course
  def self.get_independant_assignments(user_id)
    # assignment_ids = assignment_participant.where(user_id: user_id).pluck(:parent_id)
    # no_course_assignments = Assignment.where(id: assignment_ids, course_id: nil)
  end

  def self.get_assignments_in_courses(course_array)
    # assignment_list = Assignment.where(course_id: course_array)
  end

  # This method gets all tuples in the Participants table associated
  # hierarchy (q_type => course => user => score)

  def self.get_participant_entries_in_courses(course_array, user_id)
    # assignment_list = []
    assignment_list = get_assignments_in_courses(course_array)
    independant_assignments = get_independant_assignments(user_id)
    assignment_list.concat(independant_assignments)

    # questionnaireHash = get_participants_score(assignment_list)
  end

  # This method gets all tuples in the Participants table associated
  # hierarchy (q_type => course => user => score).
  def self.get_participant_entries_in_assignment(assignment_id)
    assignment_list = []
    assignment_list << Assignment.find(assignment_id)
    # questionnaireHash = get_participant_entries_in_assignment_list(assignment_list)
  end

  # This method returns the participants score grouped by course, grouped by questionnaire type.
  # End result is a hash (q_type => (course => (user => score)))
  def self.get_participants_score(assignment_list)
    q_type_hash = {}
    questionnaire_response_type_hash = {"ReviewResponseMap" => "ReviewQuestionnaire",
                                        "MetareviewResponseMap" => "MetareviewQuestionnaire",
                                        "FeedbackResponseMap" => "AuthorFeedbackQuestionnaire",
                                        "TeammateReviewResponseMap" => "TeammateReviewQuestionnaire",
                                        "BookmarkRatingResponseMap" => "BookmarkRatingQuestionnaire"}

    # Get all participants of the assignment list
    participant_list = assignment_participant.where(parent_id: assignment_list.pluck(:id)).uniq

    # Get all teams participated in the given assignment list.
    team_list = Team.where("parent_id IN (?) AND type = ?", assignment_list.pluck(:id), 'assignmentTeam').uniq

    # Get mapping of participant and team with corresponding assignment.
    # "participant" => {participantId => {"self" => <ParticipantRecord>, "assignment" => <assignmentRecord>}}
    # "team" => {teamId => <assignmentRecord>}
    assignment_map = get_assignment_mapping(assignment_list, participant_list, team_list)

    # Aggregate total reviewee list
    reviewee_list = []
    reviewee_list = participant_list.pluck(:id)
    reviewee_list.concat(team_list.pluck(:id)).uniq!

    # Get scores from ScoreCache for computed reviewee list.
    scores = ScoreCache.where("reviewee_id IN (?) and object_type IN (?)", reviewee_list, questionnaire_response_type_hash.keys)

    for score_entry in scores
      reviewee_user_id_list = []
      if assignment_map["team"].key?(score_entry.reviewee_id)
        # Reviewee is a team. Actual Reviewee will be users of the team.
        team_user_ids = teams_user.where(team_id: score_entry.reviewee_id).pluck(:user_id)
        reviewee_user_id_list.concat(team_user_ids)
        course_id = assignment_map["team"][score_entry.reviewee_id].try(:course_id).to_i
      else
        # Reviewee is an individual participant.
        reviewee_user_id_list << assignment_map["participant"][score_entry.reviewee_id]["self"].try(:user_id)
        course_id = assignment_map["participant"][score_entry.reviewee_id]["assignment"].try(:course_id).to_i
      end

      questionnaire_type = questionnaire_response_type_hash[score_entry.object_type]

      add_score_to_resultant_hash(q_type_hash, questionnaire_type, course_id, reviewee_user_id_list, score_entry.score)
    end

    q_type_hash
  end

  # This method adds score to all the revieweeUser in q_type_hash.
  # Later, q_type_hash will contain the final computer leaderboard.
  def self.add_score_to_resultant_hash(q_type_hash, questionnaire_type, course_id, reviewee_user_id_list, score_entry_score)
    if reviewee_user_id_list
      # Loop over all the reviewee_user_id.
      for reviewee_user_id in reviewee_user_id_list
        if q_type_hash.fetch(questionnaire_type, {}).fetch(course_id, {}).fetch(reviewee_user_id, nil).nil?
          user_hash = {}
          user_hash[reviewee_user_id] = [score_entry_score, 1]

          if q_type_hash.fetch(questionnaire_type, {}).fetch(course_id, nil).nil?
            if q_type_hash.fetch(questionnaire_type, nil).nil?
              course_hash = {}
              course_hash[course_id] = user_hash

              q_type_hash[questionnaire_type] = course_hash
            end

            q_type_hash[questionnaire_type][course_id] = user_hash
          end

          q_type_hash[questionnaire_type][course_id][reviewee_user_id] = [score_entry_score, 1]
        else
          # reviewee_user_id exist in q_type_hash. Update score.
          current_user_score = q_type_hash[questionnaire_type][course_id][reviewee_user_id]
          current_total_score = current_user_score[0] * current_user_score[1]
          current_user_score[1] += 1
          current_user_score[0] = (current_total_score + score_entry_score) / current_user_score[1]
        end
      end
    end
  end

  # This method creates a mapping of participant and team with corresponding assignment.
  # "participant" => {participantId => {"self" => <ParticipantRecord>, "assignment" => <assignmentRecord>}}
  # "team" => {teamId => <assignmentRecord>}
  def self.get_assignment_mapping(assignment_list, participant_list, team_list)
    result_hash = {"participant" => {}, "team" => {}}
    assignment_hash = {}
    # Hash all the assignments for later fetching them by assignment.id
    for assignment in assignment_list
      assignment_hash[Assignment.id] = Assignment
    end
    # Loop over all the participants to get corresponding assignment by parent_id
    for participant in participant_list
      result_hash["participant"][participant.id] = {}
      result_hash["participant"][participant.id]["self"] = participant
      result_hash["participant"][participant.id]["assignment"] = assignment_hash[participant.parent_id]
    end
    # Loop over all the teams to get corresponding assignment by parent_id
    for team in team_list
      result_hash["team"][team.id] = assignment_hash[team.parent_id]
    end

    result_hash
  end

  # This method does a destructive sort on the computed scores hash so
  # that it can be mined for personal achievement information
  def self.sort_hash(q_type_hash)
    result = {}
    # Deep-copy of Hash
    result = Marshal.load(Marshal.dump(q_type_hash))

    result.each do |q_type, course_hash|
      course_hash.each do |course_id, user_score_hash|
        user_score_sort_array = user_score_hash.sort {|a, b| b[1][0] <=> a[1][0] }
        result[q_type][course_id] = user_score_sort_array
      end
    end
    result
  end

  # This method takes the sorted computed score hash structure and mines
  # it for personal achievement information.
  def self.extract_personal_achievements(cs_hash, course_id_list, user_id)
    # Get all the possible accomplishments from Leaderboard table
    leaderboard_records = Leaderboard.all
    course_accomplishment_hash = {}
    accomplishment_map = {}

    # Create map of accomplishment with its name
    for leaderboard_record in leaderboard_records
      accomplishment_map[leaderboard_record.q_type] = leaderboard_record.name
    end

    cs_sorted_hash = Leaderboard.sort_hash(cs_hash)

    for course_id in course_id_list
      for accomplishment in accomplishment_map.keys
        # Get score for current questionnaire_type/accomplishment, course_id and user_id from cs_hash
        score = cs_hash.fetch(accomplishment, {}).fetch(course_id, {}).fetch(user_id, nil)
        next unless score
        if course_accomplishment_hash[course_id].nil?
          course_accomplishment_hash[course_id] = []
        end
        # Calculate rank of current user
        rank = 1 + cs_sorted_hash[accomplishment][course_id].index([user_id, score])
        total = cs_sorted_hash[accomplishment][course_id].length

        course_accomplishment_hash[course_id] << {accomp: accomplishment_map[accomplishment],
                                                  score: score[0],
                                                  rankStr: "#{rank} of #{total}"}
      end
    end
    course_accomplishment_hash
  end

  # Returns string for Top N Leaderboard Heading or accomplishments entry
  def self.leaderboard_heading(q_type_id)
    lt_entry = Leaderboard.find_by q_type(q_type_id)
    if lt_entry
      lt_entry.name
    else
      "No Entry"
    end
  end
end
