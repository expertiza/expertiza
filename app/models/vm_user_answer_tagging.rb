class VmUserAnswerTagging
  def initialize(user, percentage, no_tagged, no_not_tagged, no_taggable, no_not_taggable)
    @user = user
    @percentage = percentage
    @no_tagged = no_tagged
    @no_not_tagged = no_not_tagged
    @no_taggable = no_taggable
    @no_not_taggable = no_not_taggable
  end

  attr_accessor :user

  attr_accessor :percentage

  attr_accessor :no_tagged

  attr_accessor :no_not_tagged

  attr_accessor :no_taggable

  attr_accessor :no_not_taggable
end
