require_relative '../rails_helper'

describe 'Submission deadline reminder email' do

  it 'should send reminder email for submission deadline to signed-up users ' do
    #Delayed::Worker.delay_jobs = false
    id = 2
    @name = "user"

    #due_at = DateTime.now + 120
    #seconds_until_due = due_at - Time.now
    #minutes_until_due = seconds_until_due / 60
    due_at = DateTime.now.advance(:minutes => +2)

    #puts DateTime.now
    #puts due_at
    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at1 - curr_time).to_i/60) *60
    Delayed::Job.delete_all
    Delayed::Job.count.should == 0

    dj = Delayed::Job.enqueue(DelayedMailer.new(id, "submission", due_at), 1, time_in_min)

    Delayed::Job.count.should == 1
    # dj=Delayed::Job.enqueue(DelayedMailer.new(@assignment.id, deadline_type, duedates[i].due_at.to_s(:db)) , 1, diff.minutes.from_now)
    #ActionMailer::Base.deliveries.last.should include("Message regarding submission for assignment")
    #mm = Delayed::Job.last.handler
    Delayed::Job.last.handler.should include("deadline_type: submission")
  end
end

describe 'Resubmission deadline reminder email' do

  it 'should send reminder email for resubmission deadline to reviewers ' do

    id = 2
    @name = "user"
    due_at = DateTime.now.advance(:minutes => +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at1 - curr_time).to_i/60) *60
    Delayed::Job.delete_all
    Delayed::Job.count.should == 0

    dj = Delayed::Job.enqueue(DelayedMailer.new(id, "resubmission", due_at), 1, time_in_min)

    Delayed::Job.count.should == 1
    Delayed::Job.last.handler.should include("deadline_type: resubmission")
  end
end

describe 'Review deadline reminder email' do

  it 'should send reminder email for review deadline to reviewers ' do

    id = 2
    @name = "user"
    due_at = DateTime.now.advance(:minutes => +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at1 - curr_time).to_i/60) *60
    Delayed::Job.delete_all
    Delayed::Job.count.should == 0

    dj = Delayed::Job.enqueue(DelayedMailer.new(id, "review", due_at), 1, time_in_min)

    Delayed::Job.count.should == 1
    Delayed::Job.last.handler.should include("deadline_type: review")

  end
end

describe 'Metareview deadline reminder email' do

  it 'should send reminder email for Metareview deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.advance(:minutes => +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at1 - curr_time).to_i/60) *60
    Delayed::Job.delete_all
    Delayed::Job.count.should == 0

    dj = Delayed::Job.enqueue(DelayedMailer.new(id, "metareview", due_at), 1, time_in_min)

    Delayed::Job.count.should == 1
    Delayed::Job.last.handler.should include("deadline_type: metareview")

  end
end

describe 'Drop Topic deadline reminder email' do

  it 'should send reminder email for drop topic deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.advance(:minutes => +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at1 - curr_time).to_i/60) *60
    Delayed::Job.delete_all
    Delayed::Job.count.should == 0

    dj = Delayed::Job.enqueue(DelayedMailer.new(id, "drop_topic", due_at), 1, time_in_min)

    Delayed::Job.count.should == 1
    Delayed::Job.last.handler.should include("deadline_type: drop_topic")
  end
end

describe 'Signup deadline reminder email' do

  it 'should send reminder email for signup deadline to reviewers ' do

    id = 2
    @name = "user"
    due_at = DateTime.now.advance(:minutes => +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at1 - curr_time).to_i/60) *60
    Delayed::Job.delete_all
    Delayed::Job.count.should == 0

    dj = Delayed::Job.enqueue(DelayedMailer.new(id, "signup", due_at), 1, time_in_min)

    Delayed::Job.count.should == 1
    Delayed::Job.last.handler.should include("deadline_type: signup")
  end
end

describe 'Team formation deadline reminder email' do

  it 'should send reminder email for team formation deadline to reviewers ' do

    id = 2
    @name = "user"
    due_at = DateTime.now.advance(:minutes => +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at1 - curr_time).to_i/60) *60
    Delayed::Job.delete_all
    Delayed::Job.count.should == 0

    dj = Delayed::Job.enqueue(DelayedMailer.new(id, "team_formation", due_at), 1, time_in_min)

    Delayed::Job.count.should == 1
    Delayed::Job.last.handler.should include("deadline_type: team_formation")
  end
end