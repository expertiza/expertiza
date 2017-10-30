class VmUserAnswerTagging
  def initialize(user, percentage, no_tagged, no_not_tagged, no_tagable)
    @user = user
    @percentage = percentage
    @no_tagged = no_tagged
    @no_not_tagged = no_not_tagged
    @no_tagable = no_tagable
  end

  attr_reader :user

  attr_reader :percentage

  attr_reader :no_tagged

  attr_reader :no_not_tagged

  attr_reader :no_tagable
end
