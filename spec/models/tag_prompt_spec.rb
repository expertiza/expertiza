require 'rails_helper'

describe TagPrompt do
  let(:ct_criterion) { Criterion.new id: 1, type: 'Criterion', seq: 1.0, txt: 'test txt', weight: 1 }
  let(:ct_cbox) { Checkbox.new id: 1, type: 'Checkbox', seq: 1.0, txt: 'test txt', weight: 1 }
  let(:ct_text) { TextArea.new id: 1, type: 'TextArea', seq: 1.0, txt: 'test txt', weight: 1 }
  let(:an_long) { Answer.new question: ct_criterion, answer: 5, comments: 'test comments' }
  let(:an_long_text) { Answer.new question: ct_text, answer: 5, comments: 'test comments' }
  let(:an_cb) { Answer.new question: ct_cbox, answer: 1 }
  let(:an_short) { Answer.new question: ct_criterion, answer: 5, comments: 'yes' }
  let(:tp) { TagPrompt.new(prompt: 'test prompt', desc: 'test desc', control_type: 'Checkbox') }
  let(:tp2) { TagPrompt.new(prompt: 'test prompt2', desc: 'test desc2', control_type: 'Slider') }
  let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, question_type: 'Criterion', answer_length_threshold: 5 }
  let(:tag_dep_slider) { TagPromptDeployment.new id: 2, tag_prompt: tp2, question_type: 'Criterion', answer_length_threshold: 5 }
  let(:answer_tag) { AnswerTag.new(tag_prompt_deployment_id: 2, answer: an_long, user_id: 1, value: 1) }

  it 'is valid with valid attributes' do
    expect(TagPrompt.new(prompt: 'test prompt', desc: 'test desc', control_type: 'Checkbox')).to be_valid
  end

  it 'is invalid without valid attributes' do
    expect(TagPrompt.new).not_to be_valid
  end

  it 'returns a checkbox when the control_type is checkbox' do
    expect(tp.html_control(tag_dep, an_long, 1)).to include('input type="checkbox"')
  end

  it 'returns a slider when the control_type is slider' do
    expect(tp2.html_control(tag_dep_slider, an_long, 1)).to include('input type="range"')
  end

  it 'returns a slider with a value of 1 when user 1 has tagged an answer with 1' do
    allow(AnswerTag).to receive(:where).and_return([answer_tag])
    expect(tp2.html_control(tag_dep_slider, an_long, 1)).to include('input type="range"', 'value="1"')
  end

  it "returns a slider without a value when user 2 hasn't tagged an answer with 1" do
    allow(AnswerTag).to receive(:where).and_return([])
    expect(tp2.html_control(tag_dep_slider, an_long, 2)).not_to include('value="1"')
  end

  it 'returns an empty string when the question_type is not Criterion' do
    expect(tp.html_control(tag_dep, an_cb, 1)).to eql('')
  end

  it 'returns an empty string when the answer is too short' do
    expect(tp2.html_control(tag_dep_slider, an_short, 1)).to eql('')
  end

  it 'returns an empty string when the answer is long but the control type is not Criterion' do
    expect(tp2.html_control(tag_dep_slider, an_long_text, 1)).to eql('')
  end
end
