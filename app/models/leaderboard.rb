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
  def self.Get_Independant_Assignments(user_id)
    assignment_ids = Assignment_Participant.where(user_id: user_id).pluck(:parent_id)
    no_course_assignments = Assignment.where(id: assignment_ids, course_id: nil)
  end

  def self.Get_Assignments_In_Courses(course_array)
    Assignment_List = Assignment.where(course_id: course_array)
  end

  # This method gets all tuples in the Participants table associated
  # hierarchy (q_Type => course => user => score)

  def self.Get_Participant_Entries_In_Courses(course_array, user_id)
    Assignment_List = []
    Assignment_List = Get_Assignments_In_Courses(course_array)
    Independant_Assignments = Get_Independant_Assignments(user_id)
    Assignment_List.concat(Independant_Assignments)

#questionnaireHash = get_Participants_Score(Assignment_List)
  end

  # This method gets all tuples in the Participants table associated
  # hierarchy (q_Type => course => user => score).
  def self.get_Participant_Entries_In_Assignment(assignment_ID)
    Assignment_List = []
    Assignment_List << Assignment.find(assignment_ID)
#questionnaireHash = get_Participant_Entries_In_Assignment_List(Assignment_List)
  end

  # This method returns the participants score grouped by course, grouped by questionnaire type.
  # End result is a hash (q_Type => (course => (user => score)))
  def self.get_Participants_Score(Assignment_List)
    q_Type_Hash = {}
    questionnaire_Response_Type_Hash = {"ReviewResponseMap" => "ReviewQuestionnaire",
                                     "MetareviewResponseMap" => "MetareviewQuestionnaire",
                                     "FeedbackResponseMap" => "AuthorFeedbackQuestionnaire",
                                     "TeammateReviewResponseMap" => "TeammateReviewQuestionnaire",
                                     "BookmarkRatingResponseMap" => "BookmarkRatingQuestionnaire"}

    # Get all participants of the assignment list
    participant_List = Assignment_Participant.where(parent_id: Assignment_List.pluck(:id)).uniq

    # Get all teams participated in the given assignment list.
    team_List = Team.where("parent_id IN (?) AND type = ?", Assignment_List.pluck(:id), 'AssignmentTeam').uniq

    # Get mapping of participant and team with corresponding assignment.
    # "participant" => {participantId => {"self" => <ParticipantRecord>, "assignment" => <AssignmentRecord>}}
    # "team" => {teamId => <AssignmentRecord>}
    assignment_Map = get_assignment_Mapping(Assignment_List, participant_List, team_List)

    # Aggregate total reviewee list
    reviewee_List = []
    reviewee_List = participant_List.pluck(:id)
    reviewee_List.concat(team_List.pluck(:id)).uniq!

    # Get scores from ScoreCache for computed reviewee list.
    scores = ScoreCache.where("reviewee_id IN (?) and object_type IN (?)", reviewee_List, questionnaire_Response_Type_Hash.keys)

    for score_Entry in scores
      reviewee_User_Id_List = []
      if assignment_Map["team"].key?(score_Entry.reviewee_id)
        # Reviewee is a team. Actual Reviewee will be users of the team.
        team_User_Ids = Teams_User.where(team_id: score_Entry.reviewee_id).pluck(:user_id)
        reviewee_User_Id_List.concat(team_User_Ids)
        course_Id = assignment_Map["team"][score_Entry.reviewee_id].try(:course_id).to_i
      else
        # Reviewee is an individual participant.
        reviewee_User_Id_List << assignment_Map["participant"][score_Entry.reviewee_id]["self"].try(:user_id)
        course_Id = assignment_Map["participant"][score_Entry.reviewee_id]["assignment"].try(:course_id).to_i
      end

      questionnaire_Type = questionnaire_Response_Type_Hash[score_Entry.object_type]

      add_Score_To_Resultant_Hash(q_Type_Hash, questionnaire_Type, course_Id, reviewee_User_Id_List, score_Entry.score)
    end

    q_Type_Hash
  end

  # This method adds score to all the revieweeUser in q_Type_Hash.
  # Later, q_Type_Hash will contain the final computer leaderboard.
  def self.add_Score_To_Resultant_Hash(q_Type_Hash, questionnaire_Type, course_Id, reviewee_User_Id_List, score_Entry_Score)
    if reviewee_User_Id_List
      # Loop over all the reviewee_User_Id.
      for reviewee_User_Id in reviewee_User_Id_List
        if q_Type_Hash.fetch(questionnaire_Type, {}).fetch(course_Id, {}).fetch(reviewee_User_Id, nil).nil?
          user_Hash = {}
          user_Hash[reviewee_User_Id] = [score_Entry_Score, 1]

          if q_Type_Hash.fetch(questionnaire_Type, {}).fetch(course_Id, nil).nil?
            if q_Type_Hash.fetch(questionnaire_Type, nil).nil?
              course_Hash = {}
              course_Hash[course_Id] = user_Hash

              q_Type_Hash[questionnaire_Type] = course_Hash
            end

            q_Type_Hash[questionnaire_Type][course_Id] = user_Hash
          end

          q_Type_Hash[questionnaire_Type][course_Id][reviewee_User_Id] = [score_Entry_Score, 1]
        else
          # reviewee_User_Id exist in q_Type_Hash. Update score.
          current_User_Score = q_Type_Hash[questionnaire_Type][course_Id][reviewee_User_Id]
          current_Total_Score = current_User_Score[0] * current_User_Score[1]
          current_User_Score[1] += 1
          current_User_Score[0] = (current_Total_Score + score_Entry_Score) / current_User_Score[1]
        end
      end
    end
  end

  # This method creates a mapping of participant and team with corresponding assignment.
  # "participant" => {participantId => {"self" => <ParticipantRecord>, "assignment" => <AssignmentRecord>}}
  # "team" => {teamId => <AssignmentRecord>}
  def self.get_assignment_Mapping(Assignment_List, participant_List, team_List)
    result_Hash = {"participant" => {}, "team" => {}}
    assignment_Hash = {}
    # Hash all the assignments for later fetching them by assignment.id
    for assignment in Assignment_List
      assignment_Hash[assignment.id] = assignment
    end
    # Loop over all the participants to get corresponding assignment by parent_id
    for participant in participant_List
      result_Hash["participant"][participant.id] = {}
      result_Hash["participant"][participant.id]["self"] = participant
      result_Hash["participant"][participant.id]["assignment"] = assignment_Hash[participant.parent_id]
    end
    # Loop over all the teams to get corresponding assignment by parent_id
    for team in team_List
      result_Hash["team"][team.id] = assignment_Hash[team.parent_id]
    end

    result_Hash
 end

  # This method does a destructive sort on the computed scores hash so
  # that it can be mined for personal achievement information
  def self.sort_Hash(q_Type_Hash)
    result = {}
    # Deep-copy of Hash
    result = Marshal.load(Marshal.dump(q_Type_Hash))

    result.each do |q_Type, course_Hash|
      course_Hash.each do |course_Id, user_Score_Hash|
        user_Score_Sort_Array = user_Score_Hash.sort {|a, b| b[1][0] <=> a[1][0] }
        result[q_Type][course_Id] = user_Score_Sort_Array
      end
    end
    result
  end

  # This method takes the sorted computed score hash structure and mines
  # it for personal achievement information.
  def self.extract_Personal_Achievements(cs_Hash, course_Id_List, user_Id)
    # Get all the possible accomplishments from Leaderboard table
    leaderboard_Records = Leaderboard.all
    course_Accomplishment_Hash = {}
    accomplishment_Map = {}

    # Create map of accomplishment with its name
    for leaderboard_Record in leaderboard_Records
      accomplishment_Map[leaderboard_Record.q_Type] = leaderboard_Record.name
    end

    cs_Sorted_Hash = Leaderboard.sort_Hash(cs_Hash)

    for course_Id in course_Id_List
      for accomplishment in accomplishment_Map.keys
        # Get score for current questionnaire_Type/accomplishment, course_Id and user_Id from cs_Hash
        score = cs_Hash.fetch(accomplishment, {}).fetch(course_Id, {}).fetch(user_Id, nil)
        next unless score
        if course_Accomplishment_Hash[course_Id].nil?
          course_Accomplishment_Hash[course_Id] = []
        end
        # Calculate rank of current user
        rank = 1 + cs_Sorted_Hash[accomplishment][course_Id].index([user_Id, score])
        total = cs_Sorted_Hash[accomplishment][course_Id].length

        course_Accomplishment_Hash[course_Id] << {accomp: accomplishment_Map[accomplishment],
                                               score: score[0],
                                               rankStr: "#{rank} of #{total}"}
      end
    end
    course_Accomplishment_Hash
  end

  # Returns string for Top N Leaderboard Heading or accomplishments entry
  def self.leaderboard_Heading(q_Type_id)
    lt_entry = Leaderboard.find_by_q_Type(q_Type_id)
    if lt_entry
      lt_entry.name
    else
      "No Entry"
    end
  end
end
