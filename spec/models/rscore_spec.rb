describe Rscore do
  describe '#initialize' do
    it 'allows max, min, and avg to be accessible' do
      myscore = {
        quiz: {
          scores: {
            max: 95,
            min: 88,
            avg: 90
          }
        }
      }
      rscore = Rscore.new(myscore, :quiz)
      expect(rscore.my_max).to eq(95)
      expect(rscore.my_min).to eq(88)
      expect(rscore.my_avg).to eq(90)
      expect(rscore.my_type).to eq(:quiz)
    end
  end
end
