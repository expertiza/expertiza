describe 'Airbrake-1781551925379466692' do
  let(:assignment) { build(:assignment, id: 1) }
  let(:assignment_questionaire1) { build(:assignment_questionaire1, assignment_id: 1, used_in_round: 2) }
  let(:assignment_due_date) do
    build(:assignment_due_date, parent_id: 1, due_at: '2011-11-11 11:11:11 UTC', deadline_name: 'Review',
                                description_url: 'https://expertiza.ncsu.edu/', round: 2)
  end

  before(:each) do
    questionnaire = Questionnaire.new
    @qs = VmQuestionResponse.new(questionnaire, assignment)
    # @list_of_reviews = [Response.new(id: 1)]
    @qs.instance_variable_set(:@list_of_reviews, [instance_double('Response', response_id: 1)])
    @qs.instance_variable_set(:@list_of_rows, [VmQuestionResponseRow.new('', 1, 1, 5, 0)])
  end

  it 'can deal with comment is not nil, with one comments greater than 10' do
    # @list_of_rows = [VmQuestionResponseRow.new('', 1, 1, 5, 0)]
    allow(Answer).to receive(:where).with(any_args)
                                    .and_return([double('Answer', question_id: 1, response_id: 1, comments: 'one two three four five six seven eight nine ten eleven'),
                                                 double('Answer', question_id: 1, response_id: 1, comments: '233')])
    expect { @return_value = @qs.number_of_comments_greater_than_10_words }.not_to raise_error(NoMethodError)
    expect(@return_value).to be_an_instance_of(Array)
    expect(@return_value[0]).to be_an_instance_of(RSpec::Mocks::InstanceVerifyingDouble)
    expect(@qs.instance_variable_get(:@list_of_rows)[0].metric_hash["> 10 Word Comments"]).to eq(1)
  end

  it 'can deal with comment is not nil, with two comments greater than 10' do
    allow(Answer).to receive(:where).with(any_args)
                                    .and_return([double('Answer', question_id: 1, response_id: 1, comments: 'one two three four five six seven eight nine ten eleven'),
                                                 double('Answer', question_id: 1, response_id: 1, comments: 'one two three four five six seven eight nine ten eleven')])
    expect { @return_value = @qs.number_of_comments_greater_than_10_words }.not_to raise_error(NoMethodError)
    expect(@return_value).to be_an_instance_of(Array)
    expect(@return_value[0]).to be_an_instance_of(RSpec::Mocks::InstanceVerifyingDouble)
    expect(@qs.instance_variable_get(:@list_of_rows)[0].metric_hash["> 10 Word Comments"]).to eq(2)
  end

  it 'can deal with comment is nil' do
    allow(Answer).to receive(:where).with(any_args)
                                    .and_return([double('Answer', question_id: 1, response_id: 1, comments: nil)])
    expect { @return_value = @qs.number_of_comments_greater_than_10_words }.not_to raise_error(NoMethodError)
    expect(@return_value).to be_an_instance_of(Array)
    expect(@return_value[0]).to be_an_instance_of(RSpec::Mocks::InstanceVerifyingDouble)
    expect(@qs.instance_variable_get(:@list_of_rows)[0].metric_hash["> 10 Word Comments"]).to eq(0)
  end
end

describe 'Aribrake-1805332790232222219' do
  it 'will not raise error if instance variables are not nil' do
    rc = ResponseController.new
    # http://www.rubydoc.info/github/rspec/rspec-mocks/RSpec%2FMocks%2FMessageExpectation%3Awith
    # With a stub, if the message might be received with other args as well,
    # you should stub a default value first,
    # and then stub or mock the same message using with to constrain to specific arguments.
    @assignment = nil
    allow(@assignment).to receive(:try) {}
    allow(@questionnaire).to receive(:try) {}
    allow(@assignment).to receive(:try).with('id'.to_sym).and_return(1)
    allow(@questionnaire).to receive(:try).with('id'.to_sym).and_return(1)
    create(:assignment_questionnaire)
    expect { rc.send(:set_dropdown_or_scale) }.not_to raise_error(NoMethodError)
    expect(rc.send(:set_dropdown_or_scale)).to eq('dropdown')
  end

  it 'will not raise error even if instance variables are nil' do
    rc = ResponseController.new
    @assignment = nil
    allow(@assignment).to receive(:try) {}
    allow(@questionnaire).to receive(:try) {}
    allow(@assignment).to receive(:try).with('id'.to_sym).and_return(nil)
    allow(@questionnaire).to receive(:try).with('id'.to_sym).and_return(nil)
    expect { rc.send(:set_dropdown_or_scale) }.not_to raise_error(NoMethodError)
    expect(rc.send(:set_dropdown_or_scale)).to eq('scale')
  end
end
