class ReviewMappingService
    class << self
      def automatic_review_mapping_strategy(assignment_id, participants, teams, student_review_num = 0, submission_review_num = 0, exclude_teams = false)
        participants_hash = initialize_participants_hash(participants)
        filtered_teams = filter_teams(teams, exclude_teams)
        review_strategy = create_review_strategy(participants, filtered_teams, student_review_num, submission_review_num)
        
        peer_review_strategy(assignment_id, review_strategy, participants_hash)
        assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
      end

      private

      def initialize_participants_hash(participants)
        participants_hash = {}
        participants.each { |participant| participants_hash[participant.id] = 0 }
        participants_hash
      end
      def filter_teams(teams, exclude_teams)
        exclude_teams ? teams.reject { |team| team[:submitted_hyperlinks].nil? && team[:directory_num].nil? } : teams
      end
      def create_review_strategy(participants, teams, student_review_num, submission_review_num)
        if !student_review_num.zero? && submission_review_num.zero?
          ReviewMappingHelper::StudentReviewStrategy.new(participants, teams, student_review_num)
        elsif student_review_num.zero? && !submission_review_num.zero?
          ReviewMappingHelper::TeamReviewStrategy.new(participants, teams, submission_review_num)
        end
      end
      def peer_review_strategy(assignment_id, review_strategy, participants_hash)
        teams = review_strategy.teams
        participants = review_strategy.participants
        num_participants = participants.size
  
        teams.each_with_index do |team, iterator|
          selected_participants = select_participants_for_team(team, participants, participants_hash, review_strategy, iterator, num_participants)
          create_review_mappings(assignment_id, team, selected_participants)
        end
      end
      def assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
        if needs_more_reviews?(assignment_id, review_strategy)
          participants_with_insufficient_reviews = get_participants_with_insufficient_reviews(participants_hash, review_strategy)
          teams_hash = get_teams_review_count(assignment_id)
          assign_remaining_reviewers(assignment_id, participants_with_insufficient_reviews, teams_hash)
        end
        update_last_review_mapping_time(assignment_id)
      end
  