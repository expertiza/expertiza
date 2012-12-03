require File.dirname(__FILE__) + '/../test_helper'
# Tests added wrt E702 for micro tasks
class SignUpTopicsTest < ActiveSupport::TestCase

  def new_micro_task_assignment(attributes={})
    questionnaire_id = Questionnaire.first.id
    instructorid = Instructor.first.id
    courseid = Course.first.id
    number_of_topics = SignUpTopic.count


    attributes[:name] ||=  "mt_valid_test"
    attributes[:course_id] ||= 1
    attributes[:directory_path] ||= "mt_valid_test"
    attributes[:review_questionnaire_id] ||= questionnaire_id
    attributes[:review_of_review_questionnaire_id] ||= questionnaire_id
    attributes[:author_feedback_questionnaire_id]  ||= questionnaire_id
    attributes[:instructor_id] ||= instructorid
    attributes[:course_id] ||= courseid
    attributes[:wiki_type_id] ||= 1
    attributes[:microtask] ||= true

    assignment = Assignment.new(attributes)
    assignment
  end

  def new_mt_signuptopic(attributes={})

    assignment = new_micro_task_assignment
    attributes[:topic_name] ||=  "mt_valid_test"
    attributes[:assignment_id] ||= assignment
    attributes[:max_choosers] ||= 1
    attributes[:category] ||= "test"
    attributes[:topic_identifier] ||= "E702"
    attributes[:micropayment]  ||= 10

    nw_sign_up_topic = SignUpTopic.new(attributes)
    nw_sign_up_topic
  end

  def test_valid_mt_sign_up_topic
    new_topic = new_mt_signuptopic
    assert new_topic.valid?
  end

  def test_invalid_topic_name
    new_topic = new_mt_signuptopic(:topic_name => '')
    assert_equal ["can't be blank"], new_mt_signuptopic(:topic_name => '').errors[:SignUpTopic]
  end

  def test_invalid_max_choosers
    new_topic = new_mt_signuptopic(:max_choosers => '')
    assert_equal ["can't be less than 0"], new_mt_signuptopic(:max_choosers => -1).errors[:SignUpTopic]
  end

  def test_invalid_topic_id
    new_topic = new_mt_signuptopic(:topic_identifier => '')
    assert_equal ["can't be blank"], new_mt_signuptopic(:topic_identifier => '').errors[:SignUpTopic]
  end

  def test_invalid_micropayment
    new_topic = new_mt_signuptopic(:micropayment => '')
    assert_equal ["can't be less than 0"], new_mt_signuptopic(:micropayment => -1).errors[:SignUpTopic]
  end
end


