describe 'SignUpSheetHelper' do
  describe '#check_topic_due_date_value' do
    before(:each) do
      @assignment = create(:assignment)
      @topic = create(:topic, assignment: @assignment)
      @deadline_type = create(:deadline_type)
      @deadline_right = create(:deadline_right)
      @assignment_due_date = create(:assignment_due_date,
                                    deadline_type: @deadline_type,
                                    assignment: @assignment,
                                    submission_allowed_id: @deadline_right.id,
                                    review_allowed_id: @deadline_right.id,
                                    review_of_review_allowed_id: @deadline_right.id)
    end

    it 'The check_topic_due_date_value method should not return the assignment due date' do
      due_date = helper.get_topic_deadline([@assignment_due_date], @topic.id, 1, 1)
      expect(due_date).to be_nil
    end
  end

  describe '#get_suggested_topics' do
    before(:each) do
      @assignment = create(:assignment)
    end

    it 'The get_suggested_topics method should fail' do
      expect { helper.get_suggested_topics(@assignment.id) }.to raise_exception(NoMethodError)
    end

    it 'The get_suggested_topics method should return the suggested topics' do
      session[:user] = create(:student)
      topic = helper.get_suggested_topics(@assignment.id)
      expect(topic).to be_empty
    end
  end

  describe '#get_intelligent_topic_row' do
    before(:each) do
      @assignment = create(:assignment)
      @topic1 = create(:topic, topic_name: 'Topic 1', assignment: @assignment)
      @topic2 = create(:topic, topic_name: 'Topic 2', assignment: @assignment)
      @selected_topic1 = create(:signed_up_team, topic: @topic1, is_waitlisted: 0)
      @selected_topic2 = create(:signed_up_team, topic: @topic2, is_waitlisted: 0)
      @selected_topic3 = create(:signed_up_team, topic: @topic1, is_waitlisted: 1)
      @max_team_size = 1
    end

    it 'The get_intelligent_topic_row method should render topic row with color yellow' do
      row_html = helper.get_intelligent_topic_row(@topic1, [@selected_topic1], @max_team_size)
      expect(row_html).to include('yellow')
    end

    it 'The get_intelligent_topic_row method should render topic row with color lightgray' do
      row_html = helper.get_intelligent_topic_row(@topic1, [@selected_topic3], @max_team_size)
      expect(row_html).to include('lightgray')
    end

    it 'The get_intelligent_topic_row method should render topic row with no color' do
      row_html = helper.get_intelligent_topic_row(@topic1, [@selected_topic2], @max_team_size)
      expect(row_html).to include('topic_' + @topic1.id.to_s)
    end

    it 'The get_intelligent_topic_row method should render topic row with no selected topics' do
      row_html = helper.get_intelligent_topic_row(@topic1, nil, @max_team_size)
      expect(row_html).to include('topic_' + @topic1.id.to_s)
      expect(row_html).to include('style="background-color:')
    end
  end

  describe '#render_participant_info' do
    before(:each) do
      @assignment1 = create(:assignment, name: 'final 1', directory_path: 'final_1')
      @topic1 = create(:topic, assignment: @assignment1)
      @assignment2 = create(:assignment, name: 'final 2', directory_path: 'final_2')
      @topic2 = create(:topic, assignment: @assignment2)
      @participant1 = create(:participant, assignment: @assignment1)
    end

    it 'The render_participant_info method should return an empty html' do
      name_html = helper.render_participant_info(@topic1, @assignment2, nil)
      expect(name_html).to be_empty
    end

    it 'The render_participant_info method should throw an exception' do
      expect { helper.render_participant_info(@topic1, @assignment1, [@participant1]) }.to raise_exception(NoMethodError)
    end
  end

  describe '#team_bids' do
    before(:each) do
      @assignment1 = create(:assignment, name: 'final 1', directory_path: 'final_1')
      @topic1 = create(:topic, assignment: @assignment1)
      @assignment2 = create(:assignment, name: 'final 2', directory_path: 'final_2')
      @topic2 = create(:topic, assignment: @assignment2)
      @participant1 = create(:participant, assignment: @assignment1)
    end

    it 'The team_bids method return an empty string' do
      out_string = helper.team_bids(@topic1, [@participant1])
      expect(out_string).to be_nil
    end

    it 'The team_bids method should throw an exception' do
      expect { helper.team_bids(@topic1, @assignment1, nil) }.to raise_exception(ArgumentError)
    end
  end  

end
