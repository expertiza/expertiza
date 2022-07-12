describe AwardedBadge do
  let(:awarded_badge) { build(:awarded_badge) }
  describe '#approved?' do
    context 'when the badge has been approved' do
      it 'returns true' do
        allow(awarded_badge).to receive(:approval_status).and_return(1)
        expect(awarded_badge.approved?).to be_truthy
      end
    end
    context 'when the badge has not been approved' do
      it 'returns false' do
        allow(awarded_badge).to receive(:approval_status).and_return(0)
        expect(awarded_badge.approved?).to be_falsey
      end
    end
  end
end
