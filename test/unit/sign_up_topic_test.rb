require File.dirname(__FILE__) + '/../test_helper'

class SignUpTopicTest < ActiveSupport::TestCase
  #class SignUpTopicTest < ActiveRecord::TestCase
  #fixtures :sign_up_topics
 # should_have_db_column :topic_name, :assignment_id,:max_choosers
 # should_have_many :signed_up_users,:assignment_participants

  def new_signup_topic(attributes={})
    attributes[:topic_name] ||= 'foo'
    attributes[:assignment_id]||= 1234
    attributes[:max_choosers]||=1
    attributes[:category]||= 'foocat'
    attributes[:topic_identifier]||= 9
    sign_up_topic=SignUpTopic.new(attributes)
    sign_up_topic.valid?
    sign_up_topic
  end

 # def setup
 #   SignUpTopic.delete_all
 #   @topic=SignUpTopic.create(:topic_name=>"Topic 1",:assignment_id=>Assignment.first.id,:max_choosers=>'3',:category=>"Category 1",:topic_identifier=>'1')
 # end

  #test "should not be empty" do
  #  s = SignUpTopic.new
  #  assert s.valid?
  #  assert new_signup_topic.valid?
  #end
  def test_valid
    assert new_signup_topic.valid?
  end

  def test_assignment_id
    #assert_blank new_signup_topic(:assignment_id=>450).errors[:assignment_id]
    #assert_not_equal(false,new_signup_topic(:assignment_id=>450),"Should be false")
    #@topic.assignment_id=nil;
    #assert_equal true,@topic.valid?
    assert_equal "can't be blank", new_signup_topic(:assignment_id=>'').errors[:assignment_id]
  end

  def test_topic_name
    #assert_blank new_signup_topic(:topic_name => '').errors[:topic_name]
    #assert_blank new_signup_topic(:topic_name => nil)
    assert_equal "can't be blank", new_signup_topic(:topic_name => '').errors[:topic_name]
  end

  def test_max_choosers
    assert_equal "can't be blank", new_signup_topic(:max_choosers => '').errors[:max_choosers]
  end

  def test_category
    assert_blank new_signup_topic(:category => '').errors[:category]
  end

  def test_length_topic_identifier
     assert_equal "is too long (maximum is 10 characters)", new_signup_topic(:topic_identifier => 'abcdefghijtyu').errors[:topic_identifier]
  end
end