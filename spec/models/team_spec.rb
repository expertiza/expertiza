require 'spec_helper'
require 'rails_helper'

describe Team do
     it "when team is valid" do
      FactoryGirl.build(:team,name: nil).should be_valid
     end
     


end
