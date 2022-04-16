require 'rails_helper'

describe ExportFileController do
    let(:user) { build(:student, id: 1, name: 'student1') }
    let(:answer_tag) { AnswerTag.new(tag_prompt_deployment_id: 2, answer: an_long, user_id: 1, value: 1)}
    let(:answers) { build(:answers, id: [1, 2])}

    describe '#export_tags' do
        it 'creates user' do
            allow(User).to receive(:where).with(name: 'student1').and_return(user) 
        end
        # it 'creates student' do
        #     allow(Student).to receive(:user_id)
        # end  
    end

    describe '#export_advices' do
        it 'checks if params are passed correctly' do
            controller.params = { delim_type: 'comma' }
            expect(assigns(:delim_type)).to eq(@delim_type)
        end
        it 'finds file name' do
            controller.params = {model: 'Question', id: '1'}
            expect(controller.find_delim_filename('comma', '')).to eq(['Question1.csv', ','])
        end
        # it 'checks if method doesnt generate csv data if model is not allowed' do
        #     controller.params = {model: ''}
        #     expect(@csv_data).should be_nil
        # end
    end
end



