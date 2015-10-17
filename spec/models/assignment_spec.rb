require 'spec_helper'
require 'rails_helper'

describe Assignment do
  it "when is valid" do
    create(:assignment).should be_valid
  end

  it "pending" do
  end
end
