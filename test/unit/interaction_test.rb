require File.dirname(__FILE__) + '/../test_helper'


class InteractionTest < ActiveSupport::TestCase
  # To change this template use File | Settings | File Templates.
  fixtures :teams, :participants


  # 101 add a new interaction
  def test_add_helper_interaction
    interaction = HelperInteraction.new
    interaction.comments = "deploying the project"
    interaction.number_of_minutes = 30
    interaction.status = "Not Confirmed"
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    interaction.save! # an exception is thrown if the user is invalid
   end



 # 102 add a new interaction  without number of minutes
  def test_add_helper_interaction_without_nom
    interaction = HelperInteraction.new #user = User.new
    interaction.comments = "deploying the project" #user.name = "testStudent1"
    interaction.status = "Not Confirmed"
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal 'Number of minutes is blank.', interaction.errors.on(:number_of_minutes)[0]
  end

  # 103 add a new interaction  without invalid number of minutes
  def test_add_helper_interaction_invalid_nom
    interaction = HelperInteraction.new #user = User.new
    interaction.comments = "deploying the project" #user.name = "testStudent1"
    interaction.status = "Not Confirmed"
    interaction.number_of_minutes = "abcd"
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal 'Number of minutes is blank or non-numeric.', interaction.errors.on(:number_of_minutes)
  end

 # 104 add a new interaction  without comments
  def test_add_helper_interaction_without_comments
    interaction = HelperInteraction.new
    interaction.status = "Not Confirmed"
    interaction.number_of_minutes = 30
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal 'Please enter comments.', interaction.errors.on(:comments)
  end

  # 105 add a new interaction  without interaction datetime
  def test_add_helper_interaction_without_datetime
    interaction = HelperInteraction.new
    interaction.status = "Not Confirmed"
    interaction.number_of_minutes = 30
    interaction.comments="Deploying the project"
    interaction.team_id=teams(:team0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal "Please enter date and time.", interaction.errors.on(:interaction_datetime)
  end

 # 106 add a new interaction
  def test_add_helpee_interaction
    interaction = HelpeeInteraction.new
    interaction.comments = "deploying the project"
    interaction.number_of_minutes = 30
    interaction.status = "Not Confirmed"
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    interaction.save! # an exception is thrown if the user is invalid
   end



 # 107 add a new interaction  without number of minutes
  def test_add_helpee_interaction_without_nom
    interaction = HelpeeInteraction.new #user = User.new
    interaction.comments = "deploying the project" #user.name = "testStudent1"
    interaction.status = "Not Confirmed"
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal 'Number of minutes is blank.', interaction.errors.on(:number_of_minutes)[0]
  end

  # 108 add a new interaction  without invalid number of minutes
  def test_add_helpee_interaction_invalid_nom
    interaction = HelpeeInteraction.new #user = User.new
    interaction.comments = "deploying the project" #user.name = "testStudent1"
    interaction.status = "Not Confirmed"
    interaction.number_of_minutes = "abcd"
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal 'Number of minutes is blank or non-numeric.', interaction.errors.on(:number_of_minutes)
  end

 # 109 add a new interaction  without comments
  def test_add_helpee_interaction_without_comments
    interaction = HelpeeInteraction.new
    interaction.status = "Not Confirmed"
    interaction.number_of_minutes = 30
    interaction.interaction_datetime =  Time.new
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal 'Please enter comments.', interaction.errors.on(:comments)
  end

  # 110 add a new interaction  without interaction datetime
  def test_add_helpee_interaction_without_datetime
    interaction = HelpeeInteraction.new
    interaction.status = "Not Confirmed"
    interaction.number_of_minutes = 30
    interaction.comments="Deploying the project"
    interaction.team_id=teams(:team0).id
    interaction.participant_id=participants(:par0).id
    assert !interaction.save # an exception is thrown if the user is invalid
    assert_equal "Please enter date and time.", interaction.errors.on(:interaction_datetime)
  end


end
