class VmUserAnswerTagging
  def initialize(user, no_total, no_inferred, no_taggable, no_tagged, no_not_tagged, percentage, tag_update_intervals)
    @user = user
    @no_total = no_total
    @no_inferred = no_inferred
    @no_taggable = no_taggable
    @no_tagged = no_tagged
    @no_not_tagged = no_not_tagged
    @percentage = percentage
    # E2082 Adding interval to be passed for graph plotting
    @tag_update_intervals = tag_update_intervals
  end

  attr_accessor :user, :no_total, :no_inferred, :no_taggable, :no_tagged, :no_not_tagged, :percentage, :tag_update_intervals
end
