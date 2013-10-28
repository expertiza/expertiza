#OSS change 28th Oct
#new spec test on participant
require 'spec_helper'
describe Participant do


  it { should have_many(:resubmission_times) }
  it { should have_many(:comments) }
  it { should have_many(:reviews) }
  it { should have_many(:team_reviews) }
  it { should have_many(:response_maps) }

  it{ should validate_numericality_of (:grade) }

  it "has no participants expertiza" do
    expect(Participant).to have(:no).records
    expect(Participant).to have(0).records
  end

end
