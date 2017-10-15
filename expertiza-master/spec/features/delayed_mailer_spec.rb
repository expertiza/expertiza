include DelayedTaskHelper

describe 'Submission deadline reminder email' do
  it 'is able to send reminder email for submission deadline to signed-up users ' do
    enqueue_delayed_job("submission", 2.minutes)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: submission")
  end
end

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    enqueue_delayed_job("review", 2.minutes)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: review")
  end
end

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    enqueue_delayed_job("metareview", 2.minutes)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: metareview")
  end
end

describe 'Drop Topic deadline reminder email' do
  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    enqueue_delayed_job("drop_topic", 2.minutes)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_topic")
  end
end

describe 'Signup deadline reminder email' do
  it 'is able to send reminder email for signup deadline to reviewers ' do
    enqueue_delayed_job("signup", 2.minutes)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: signup")
  end
end

describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    enqueue_delayed_job("team_formation", 2.minutes)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: team_formation")
  end
end
