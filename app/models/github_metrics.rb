class GithubMetrics
    attr_reader :participant, :assignment, :team, :token
  
    def initialize(participant_id, assignment_id = nil, token = nil)
      @participant = AssignmentParticipant.find(participant_id)
      @assignment = assignment_id ? Assignment.find(assignment_id) : @participant.assignment
      @team = @participant.team
      @token = token
      initialize_metrics
    end
  
    def process_metrics
      return handle_missing_token unless @token
      retrieve_github_data
      query_all_merge_statuses
      process_dates
      self
    end
  
    private
  
    def initialize_metrics
      @head_refs = {}
      @parsed_data = {}
      @authors = {}
      @dates = {}
      @total_additions = 0
      @total_deletions = 0
      @total_commits = 0
      @total_files_changed = 0
      @merge_status = {}
      @check_statuses = {}
    end
  
    # Move other methods from MetricsController here, making them instance methods
    # ...
  end