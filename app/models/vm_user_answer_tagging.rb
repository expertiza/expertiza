class VmUserAnswerTagging
  def initialize(user, percentage, no_tagged, no_not_tagged, no_tagable, tag_update_intervals)
    @user = user
    @percentage = percentage
    @no_tagged = no_tagged
    @no_not_tagged = no_not_tagged
    @no_tagable = no_tagable
    # E2082 Adding interval to be passed for graph plotting
    @tag_update_intervals = tag_update_intervals
  end

  attr_accessor :user

  attr_accessor :percentage

  attr_accessor :no_tagged

  attr_accessor :no_not_tagged

  attr_accessor :no_tagable

  attr_accessor :tag_update_intervals
end
