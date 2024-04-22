require 'rails_helper'

# Assuming your helper module is in the helpers folder
RSpec.describe LotteryHelper, type: :helper do
  # Test for low percentage range
  describe '#background_color_by_percentage' do
    it 'returns light red for low percentages' do
      expect(helper.background_color_by_percentage(10)).to eq('background-color: #ffcccc;')
    end

    # Test for medium percentage range
    it 'returns light orange for medium percentages' do
      expect(helper.background_color_by_percentage(50)).to eq('background-color: #ffcc99;')
    end

    # Test for high percentage range
    it 'returns light green for high percentages' do
      expect(helper.background_color_by_percentage(80)).to eq('background-color: #ccffcc;')
    end

    # Test for percentage out of range
    it 'returns no background for percentages out of range' do
      expect(helper.background_color_by_percentage(101)).to eq('background-color: none;')
      expect(helper.background_color_by_percentage(-1)).to eq('background-color: none;')
    end
  end
end
