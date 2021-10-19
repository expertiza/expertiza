class VmUserAnswerTagging
  def initialize(user, no_total, no_inferred, no_taggable, no_tagged, no_not_tagged, percentage)
    @user = user
    @no_total = no_total
    @no_inferred = no_inferred
    @no_taggable = no_taggable
    @no_tagged = no_tagged
    @no_not_tagged = no_not_tagged
    @percentage = percentage
  end

  attr_accessor :user, :no_total, :no_inferred, :no_taggable, :no_tagged, :no_not_tagged, :percentage
end
