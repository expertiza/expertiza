class SimicheckWorker < Worker
    @@deadline_type = "compare_files_with_simicheck"
  
    def perform(assignment_id)
      perform_simicheck_comparisons(assignment_id)
    end
  
    private
  
    # Similarity check refers to % text same between 2 docs
    def perform_simicheck_comparisons(assignment_id)
      PlagiarismCheckerHelper.run(assignment_id)
    end
  end