describe GradesHelper, type: :helper do
  let(:review_response) { build(:response, id: 1, map_id: 1) }
  let(:question) { build(:question) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:assignment) { build(:assignment, id: 1, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true)}
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  
  
  # describe 'get_accordion_title' do
  #   it 'should render is_first:true if last_topic is nil' do
  #    get_accordion_title(nil, 'last question')
  #    expect(response).to render_template(partial: 'response/_accordion', locals: {title: 'last question', is_first: true})
  #  end
  #  it 'should render is_first:false if last_topic is not equal to next_topic' do
  #    get_accordion_title('last question', 'next question')
  #    expect(response).to render_template(partial: 'response/_accordion', locals: {title: 'next question', is_first: false})
  #  end
  #  it 'should render nothing if last_topic is equal to next_topic' do
  #    get_accordion_title('question', 'question')
  #    expect(response).to render_template(nil)
  #  end
  # end  

  describe 'get_css_style_for_X_reputation' do
    hamer_input = [-0.1, 0, 0.5, 1, 1.5, 2, 2.1]
    lauw_input = [-0.1, 0, 0.2, 0.4, 0.6, 0.8, 0.9]
    output = %w[c1 c1 c2 c2 c3 c4 c5]
    it 'should return correct css for hamer reputations' do
      hamer_input.each_with_index do |e, i|
        expect(get_css_style_for_hamer_reputation(e)).to eq(output[i])
      end
    end
    it 'should return correct css for luaw reputations' do
      lauw_input.each_with_index do |e, i|
        expect(get_css_style_for_lauw_reputation(e)).to eq(output[i])
      end
    end
  end

  describe 'score_vector' do
    it 'should return the scores from the questions in a vector' do
      allow(Answer).to receive(:assessment_score).with(response: [review_response], questions: [question], q_types: []).and_return(75)
      @questions = {:s => [question]}
      expect(score_vector([review_response, review_response], 's')).to eq([75,75])
    end
  end

  describe 'charts' do
    it 'it should return a chart url' do
      symbol = :s
      @grades_bar_charts = {:s => nil}
      @participant_score = {symbol => {:assessments => [review_response, review_response]}}
      allow(Answer).to receive(:assessment_score).with(response: [review_response], questions: [question], q_types: []).and_return(75)
      allow(GradesController).to receive(:bar_chart).with([75,75]).and_return(
        'http://chart.apis.google.com/chart?chs=800x200&cht=bvg&chco=0000ff,ff0000,00ff00&chd=s:yoeKey,KUeoy9,9yooy9&chdl=Trend+1|Trend+2|Trend+3&chtt=Bar+Chart'
      )
      @questions = {:s => [question]}
      expect(charts(symbol).class).to eq(String)
      expect(charts(symbol)).to include ('http://chart.apis.google.com/chart')
    end 
    it 'returns nil when there is no score' do
      @participant_score = {:s => nil}
      symbol = :s
      expect(charts(symbol)).to eq(nil)
    end
  end

  describe 'type_and_max' do  
    context 'when the question is a Checkbox' do
      it 'returns 10_003' do
        row = VmQuestionResponseRow.new('Some question text', 1, 5, 95, 2)
        allow(Question).to receive(:find).with(1).and_return(question)
        allow(question).to receive(:type).and_return("Checkbox")
        allow(question).to receive(:is_a?).and_return(Checkbox)
        expect(type_and_max(row)).to eq(10_003)
      end
    end
    context 'when the question is a ScoredQuestion' do
      it 'returns the correct code adn the max score' do
        row = VmQuestionResponseRow.new('Some question text', 1, 5, 95, 2)
        allow(Question).to receive(:find).with(1).and_return(question)
        allow(question).to receive(:is_a?).and_return(ScoredQuestion)
        expect(type_and_max(row)).to eq(9311 + row.question_max_score)
      end
    end
    context 'when the question is something else' do
      it 'returns 9998' do
        row = VmQuestionResponseRow.new('Some question text', 1, 5, 95, 2)
        allow(Question).to receive(:find).with(1).and_return(question)
        allow(question).to receive(:is_a?).with(ScoredQuestion).and_return(false)
        question[:type] == 'NotACheckbox'
        expect(type_and_max(row)).to eq(9998)
      end
    end 
  end

  describe 'underlined?' do
    context 'when the comment is present' do
      it 'returns underlined' do
        score = VmQuestionResponseScoreCell.new(95, 0, 'This is a comment.')
        expect(underlined?(score)).to eq('underlined')
      end
    end
  end

  describe 'mean' do
    it 'computes the mean of an array' do
      array = [2,3,4]
      expect(mean(array)).to be(3.0)
    end
  end

  describe 'vector' do 
    context 'when there are nil scores' do
      it 'filters them out' do
        scores = {
          teams: {
            a: {
              scores: {}
            }, b: {
              scores: {
                avg: 75
              }
            }, c: {
              scores: {
                avg: 65
              }
            }
          }
        }
        expect(vector(scores)).to eq([75, 65]) 
      end 
    end
  end
end
