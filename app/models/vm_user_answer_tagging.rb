class VmUserAnswerTagging
  def initialize(user, percentage, no_tagged, no_not_tagged, no_tagable)
    @user = user
    @percentage = percentage
    @no_tagged = no_tagged
    @no_not_tagged = no_not_tagged
    @no_tagable = no_tagable
  end

  attr_accessor :user

  attr_accessor :percentage

  attr_accessor :no_tagged

  attr_accessor :no_not_tagged

  attr_accessor :no_tagable
end
