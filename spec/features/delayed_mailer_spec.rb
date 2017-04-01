require 'rails_helper'



def create_delayed_mailer(assignment_id, deadline_type, due_at)
  mail = DelayedMailer.new(assignment_id, deadline_type, due_at)
  Delayed::Job.enqueue(payload_object: mail, priority: 1, run_at:1.second.from_now)
  return mail
end

describe 'Delayed Mailer' do
  before(:all) do
  end

  before(:each) do
    # Delayed::Worker.delay_jobs = false
    @name = "user"
    @due_at = DateTime.now.in_time_zone + 1.minute

    @assignment = FactoryGirl.create(:oss_project)
    @team = FactoryGirl.create(:assignment_team)
    @team.users = FactoryGirl.create_list(:student, 5)
    @topic = FactoryGirl.create(:topic)
    @review_response_map = FactoryGirl.create(:response_map, :review_response)
    @meta_review_response_map = FactoryGirl.create(:response_map, :meta_review_response)
    @reviewer = FactoryGirl.create(:review_participant)
    @meta_reviewer = FactoryGirl.create(:review_participant)
    @assignment.sign_up_topics = [@topic]

    @assignment.participants = FactoryGirl.create_list(:participant, 2)
    @assignment.response_maps = [@review_response_map, @meta_review_response_map]
    @assignment.save

    @review_response_map.reviewer = @reviewer
    @review_response_map.save

    @meta_review_response_map.reviewer = @meta_reviewer
    @meta_review_response_map.save

    @reviewer.id = @review_response_map.reviewer_id
    @reviewer.parent_id = @assignment.id
    @reviewer.save

    @meta_reviewer.id = @meta_review_response_map.reviewer_id
    @meta_reviewer.parent_id = @assignment.id
    @meta_reviewer.save

    @team.parent_id = @assignment.id
    @team.save

    @topic.assignment = @assignment
    @topic.signed_up_teams = [FactoryGirl.create(:signed_up_team)]
    @topic.save

    @review_response_map.reviewed_object_id = @assignment.id
    @review_response_map.save

    @meta_review_response_map.reviewed_object_id = @assignment.id
    @meta_review_response_map.save

    @time_in_min = Time.zone.now
    Delayed::Job.delete_all
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  it 'is able to send reminder email for submission deadline to signed-up users ' do
    mail = create_delayed_mailer(@assignment.id, "submission", @due_at)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: submission")
    expect { mail.perform } .to change { Mailer.deliveries.count } .by(1)
  end

  it 'is able to send reminder email for review deadline to reviewers ' do
    mail = create_delayed_mailer(@assignment.id, "review", @due_at)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: review")
    expect { mail.perform } .to change { Mailer.deliveries.count } .by(1)
  end

  it 'is able to send reminder email for Metareview deadline to meta-reviewers and team members of the assignment' do
    mail = create_delayed_mailer(@assignment.id, "metareview", @due_at)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: metareview")
    expect { mail.perform } .to change { Mailer.deliveries.count } .by(2)
  end

  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    mail = create_delayed_mailer(@assignment.id, "drop_topic", @due_at)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_topic")
    expect { mail.perform } .to change { Mailer.deliveries.count } .by(1)
  end

  it 'is able to send reminder email for signup deadline to assignment participants ' do
    mail = create_delayed_mailer(@assignment.id, "signup", @due_at)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: signup")
    expect { mail.perform } .to change { Mailer.deliveries.count } .by(1)
  end
end

describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.in_time_zone + 2.minutes

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, "team_formation", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: team_formation")
  end
end

describe DelayedMailer do
  describe ".find_team_members_email_for_all_topics" do
    it "gets user emails" do
      assignment = create(:assignment)
      sign_up_topic = create(:topic)
      create(:student)
      create(:signed_up_team)
      create(:team_user)
      # deadline type and due_date are not important for this test
      dm = DelayedMailer.new(assignment.id, nil, nil)
      expect(dm.find_team_members_email_for_all_topics(sign_up_topic)).to eq(["expertiza@mailinator.com"])
    end
  end

  describe ".mail_signed_up_users" do
    it "sends emails to signed up users when no topics" do
      assignment = create(:assignment)
      dm = DelayedMailer.new(assignment.id, nil, nil)

      # Do not let these functions do anything, like sending out emails
      allow(DelayedMailer).to receive(:find_team_members_email).and_return(true)
      allow(DelayedMailer).to receive(:email_reminder).and_return(true)
      expect(dm).to receive(:find_team_members_email)
      dm.mail_signed_up_users
    end
  end

  describe ".mail_signed_up_users" do
    it "sends emails to singed up users when there are topics" do
      assignment = create(:assignment)
      sign_up_topic = create(:topic)
      dm = DelayedMailer.new(assignment.id, nil, nil)

      # Do not let these functions do anything
      allow(DelayedMailer).to receive(:find_team_members_email_for_all_topics).and_return(true)
      allow(DelayedMailer).to receive(:email_reminder).and_return(true)
      expect(dm).to receive(:find_team_members_email_for_all_topics).with([sign_up_topic])
      dm.mail_signed_up_users
    end
  end

  describe ".find_team_members_email" do
    it "gets emails of team members" do
      # deadline_type and due_date are not important for this test
      dm = DelayedMailer.new(1, nil, nil)
      user = create(:student)
      team = Team.create(parent_id: 1)
      create(:team_user, team_id: team.id, user_id: user.id)
      expect(dm.find_team_members_email).to eq(["expertiza@mailinator.com"])
    end
  end
end
