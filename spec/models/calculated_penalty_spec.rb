# frozen_string_literal: true

describe CalculatedPenalty do
  it { should belong_to :participant }
  it { should belong_to :deadline_type }
end
