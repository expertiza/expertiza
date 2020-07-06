class VmUserAnswerTagging
  def initialize(argument_hash = {})
    @user = argument_hash.fetch(:user)
    @percentage = argument_hash.fetch(:percentage)
    @no_tagged = argument_hash.fetch(:no_tagged)
    @no_not_tagged = argument_hash.fetch(:no_not_tagged)
    @no_tagable = argument_hash.fetch(:no_tagable)
  end

  attr_accessor :user

  attr_accessor :percentage

  attr_accessor :no_tagged

  attr_accessor :no_not_tagged

  attr_accessor :no_tagable
end
