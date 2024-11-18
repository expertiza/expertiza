# frozen_string_literal: true

# The `MetareviewService` class encapsulates the business logic related to managing
# metareview mappings for a given participant and their associated assignment.
class MetareviewService
  def initialize(participant)
    @participant = participant
    @assignment = participant.assignment
  end

  def metareview_mappings
    MetareviewResponseMap.where(reviewer_id: @partipant.id)
  end

  def metareview_counts
    total_metareviews = metareview_mappings.size
    completed_metareviews = metareview_mappings.count { |map| map.response.present? }
    in_progress_metareviews = total_metareviews - completed_metareviews
    { total: total_metareviews, completed: completed_metareviews, in_progress: in_progress_metareviews }
  end
end
