require 'rails_helper'

describe 'has_paper_trail' do
  it "will create Version record when create delayed jobs record" do
    PaperTrail.enabled =true
    for version in Version.all
      version.delete
    end
    Version.all.count.should == 0

    @delayed_job = DelayedJob.new
    @delayed_job.id = 1
    @delayed_job.priority = 1
    @delayed_job.attempts = 0
    @delayed_job.save
    Version.all.count.should == 1
  end
end
