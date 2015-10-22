require 'rails_helper'

describe SignUpSheet do

  describe '.add_signup_topic' do

    it 'will return an empty Hash when there are no topics' do
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { nil }
      allow(Assignment).to receive(:find) { assignment }

      allow(SignUpTopic).to receive(:where) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eql({})
    end

    it 'will return an empty Hash when there are no topics' do
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { nil }
      allow(Assignment).to receive(:find) { assignment }

      allow(SignUpTopic).to receive(:where) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eql({})
    end

  end
end