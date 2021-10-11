class SimicheckMailWorker < MailWorker
  @@deadline_type = "compare_files_with_simicheck"

  def perform(assignment_id, due_at)
    super(assignment_id, @@deadline_type, due_at)
  end

  protected

  def prepare_data
    perform_simicheck_comparisons
  end

  private

  def perform_simicheck_comparisons()
    PlagiarismCheckerHelper.run(@assignment.id)
  end
end