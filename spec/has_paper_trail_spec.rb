require 'rails_helper'

describe 'has_paper_trail' do
  it "will create Version record when create delayed jobs record" do
    PaperTrail.enabled =true
    for version in Version.all
      version.delete
    end
    expect(Version.all.count).to eq(0)

    @delayed_job = DelayedJob.new
    @delayed_job.id = 1
    @delayed_job.priority = 1
    @delayed_job.attempts = 0
    @delayed_job.save
    expect(Version.all.count).to eq(1)
  end
end
