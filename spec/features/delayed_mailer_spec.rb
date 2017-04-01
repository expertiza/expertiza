require 'rails_helper'
require 'features/helpers/delayed_task_helper'
include DelayedTaskHelper

describe 'Submission deadline reminder email' do
  it 'is able to send reminder email for submission deadline to signed-up users ' do
    send_reminder_email("submission", 2.minutes)
  end
end

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    send_reminder_email("review", 2.minutes)
  end
end

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    send_reminder_email("metareview", 2.minutes)
  end
end

describe 'Drop Topic deadline reminder email' do
  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    send_reminder_email("drop_topic", 2.minutes)
  end
end

describe 'Signup deadline reminder email' do
  it 'is able to send reminder email for signup deadline to reviewers ' do
    send_reminder_email("signup", 2.minutes)
  end
end

describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    send_reminder_email("team_formation", 2.minutes)
  end
end
