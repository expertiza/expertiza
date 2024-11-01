require 'rails_helper'

describe AnswerTag do
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1, type: 'Criterion') }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, comments: 'test comment', response_id: 1) }
  let(:tag_prompt) { TagPrompt.create id: 1, prompt: '??', desc: 'desc', control_type: 'slider' }
  let(:tag_prompt_cb) { TagPrompt.create id: 1, prompt: '??', desc: 'desc', control_type: 'checkbox' }
  let(:tag_deploy) { TagPromptDeployment.create id: 1, tag_prompt: tag_prompt, question_type: 'Criterion' }
  let(:tag_deploy_cb) { TagPromptDeployment.create id: 1, tag_prompt: tag_prompt_cb, question_type: 'Criterion' }
  let(:user) { User.new name: 'abc', fullname: 'abc xyz', email: 'abcxyz@gmail.com', password: '12345678', password_confirmation: '12345678' }

  it 'is invalid without valid attributes' do
    expect(AnswerTag.new).not_to be_valid
  end

  it 'is valid with valid attributes' do
    expect(AnswerTag.new(answer_id: 1, tag_prompt_deployment_id: 1, value: 0, user_id: 'test')).to be_valid
  end

  it 'returns a corresponding tag_prompt' do
    ans_tag = AnswerTag.create answer: answer, tag_prompt_deployment_id: tag_deploy.id, value: 0, user_id: user.id
    expect(ans_tag.tag_prompt).to eql tag_prompt
  end

  it 'returns a slider when its associated tag_prompt is a slider' do
    ans_tag = AnswerTag.create answer: answer, tag_prompt_deployment_id: tag_deploy.id, value: 0, user_id: user.id
    expect(ans_tag.tag_prompt_html_control(1)).to include('input type="range"')
  end

  it 'returns a checkbox when its associated tag_prompt is a checkbox' do
    ans_tag = AnswerTag.create answer: answer, tag_prompt_deployment_id: tag_deploy_cb.id, value: 0, user_id: user.id
    expect(ans_tag.tag_prompt_html_control(1)).to include('input type="checkbox"')
  end
end
