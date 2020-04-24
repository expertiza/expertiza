describe GradesHelper, type: :helper do
  describe 'get_accordion_title' do
    it 'should render is_first:true if last_topic is nil' do
      get_accordion_title(nil, 'last question')
      expect(response).to render_template(partial: 'response/_accordion', locals: {title: 'last question', is_first: true})
    end
    it 'should render is_first:false if last_topic is not equal to next_topic' do
      get_accordion_title('last question', 'next question')
      expect(response).to render_template(partial: 'response/_accordion', locals: {title: 'next question', is_first: false})
    end
    it 'should render nothing if last_topic is equal to next_topic' do
      get_accordion_title('question', 'question')
      expect(response).to render_template(nil)
    end
  end

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

  describe 'has_team_and_metareview' do
    before(:each) do
      @assignment = create(:assignment, max_team_size: 1)
    end

    it 'should correctly identify the assignment from an assignment id' do
      params[:id] = @assignment.id
      result = Assignment.find(params[:id])
      expect(result).to eq(@assignment)
    end

    it 'should correctly identify the assignment from a participant id' do
      participant = create(:participant, assignment: @assignment)
      params[:id] = participant.id
      result = Participant.find(params[:id]).parent_id
      expect(result).to eq(@assignment.id)
    end

    it 'should return 0 for an assignment without a team or a metareview deadline after a view action' do
      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: false, has_metareview: false, true_num: 0}
    end

    it 'should return 1 for an assignment with a team but no metareview deadline after a view action' do
      @assignment.max_team_size = 2
      @assignment.save
      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: true, has_metareview: false, true_num: 1}
    end
  end

  describe 'type_and_max' do
    it 'should fail when passing in nil row value' do
      expect { type_and_max(nil) }.to raise_exception(NoMethodError)
    end
  end

  describe 'underlined' do
    it 'should fail when passing in nil score value' do
      expect { underlined?(nil) }.to raise_exception(NoMethodError)
    end
  end

  describe 'retrieve_questions' do
    it 'should fail when passing in nil values for questionnaires and assignment_id' do
      expect { retrieve_questions(nil,nil) }.to raise_exception(NoMethodError)
    end
  end

  describe 'review_done_by_course_staff' do
    it 'should return false' do
      expect(review_done_by_course_staff?(nil)).to eq(false)
    end

  end
end
