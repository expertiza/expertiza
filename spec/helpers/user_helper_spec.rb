RSpec.describe UserHelper do
  describe "#yesorno" do
    it "returns 'yes' when passed true" do
      expect(helper.yesorno(true)).to eq('yes')
    end

    it "returns 'no' when passed false" do
      expect(helper.yesorno(false)).to eq('no')
    end

    it "returns an empty string when passed anything other than a boolean" do
      expect(helper.yesorno(nil)).to eq('')
      expect(helper.yesorno(1)).to eq('')
      expect(helper.yesorno('foo')).to eq('')
    end
  end
end
