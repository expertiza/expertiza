require 'test_helper'

class LogEntryTest < ActiveSupport::TestCase
  fixtures :log_entries
  fixtures :users
  test "should require all fields" do
    log = LogEntry.new
    log.user = users(:admin)
    log.location = 'test/unit'
    log.entry = 'test validity if log entry'
    log.save
    assert_true log.valid?
  end
  test "should have different log ids" do
    log = LogEntry.new
    #since we haven't assigned id to log entry it should be nil
    assert(log.id.nil?, "Log id created")
  end
  test "should have log entry" do
    log = LogEntry.new
    log.entry = 'User created'
    log.save
    #checking if log entry is created
    assert LogEntry.find_by_entry('User created').valid?
  end

  test "should have log location" do
    log = LogEntry.new
    log.location = 'tests/unit'
    log.save
    #checking if log location is not nil
    assert_false LogEntry.find_all_by_location('tests/unit').nil?
  end


  test "log entry for assignment creation" do
    assignment = AssignmentController.new
    assert LogEntry.find_all_by_entry('New assignment created from scratch')
  end

  test "log entry for user creation" do
    user = User.new
    assert LogEntry.find_all_by_entry('New user created')
    assert LogEntry.find_all_by_location('users_controller/create')
  end

  test "log entry for participant added" do
    participant = Participant.new
    assert LogEntry.find_all_by_entry('added participants to assignment')
    assert LogEntry.find_all_by_location('participants_controller/add')
  end

  test "log entry for review mapping controller add" do
    rm = ReviewMappingController.new
    assert LogEntry.find_all_by_entry('reviewer added to an assignment')
    assert LogEntry.find_all_by_location('review_mapping_controller/add')
  end
end
