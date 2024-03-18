describe QuestionAdvice do
  let(:questionnaire) { Questionnaire.new id: 1, name: 'abc', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:question) { build(:question, id: 1) }
  let(:question_advice) { build(:question_advice) }
  describe 'has correct csv values?' do
    before(:each) do
      create(:questionnaire)
      create(:question)
      create(:question_advice)
      @options = {}
    end
    def generated_csv(t_questionnaire, t_options)
      delimiter = ','
      CSV.generate(col_sep: delimiter) do |csv|
        csv << QuestionAdvice.export_fields(t_options)
        QuestionAdvice.export(csv, t_questionnaire.id, t_options)
      end
    end

    it 'checks_if_csv has the correct question advice data' do
      expected_csv = File.read('spec/features/question_advice_export_csv/expected_question_advice_export_csv.txt')
      expect(generated_csv(questionnaire, @options)).to eq(expected_csv)
    end
  end
end
