describe QuestionAdvice do
  let(:itemnaire) { Questionnaire.new id: 1, name: 'abc', private: 0, min_item_score: 0, max_item_score: 10, instructor_id: 1234 }
  let(:item) { build(:item, id: 1) }
  let(:item_advice) { build(:item_advice) }
  describe 'has correct csv values?' do
    before(:each) do
      create(:itemnaire)
      create(:item)
      create(:item_advice)
      @options = {}
    end
    def generated_csv(t_itemnaire, t_options)
      delimiter = ','
      CSV.generate(col_sep: delimiter) do |csv|
        csv << QuestionAdvice.export_fields(t_options)
        QuestionAdvice.export(csv, t_itemnaire.id, t_options)
      end
    end

    it 'checks_if_csv has the correct item advice data' do
      expected_csv = File.read('spec/features/item_advice_export_csv/expected_item_advice_export_csv.txt')
      expect(generated_csv(itemnaire, @options)).to eq(expected_csv)
    end
  end
end
