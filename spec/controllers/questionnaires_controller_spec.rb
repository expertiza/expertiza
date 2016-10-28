
require 'rails_helper'
describe QuestionnairesController do

  describe '#import' do
=begin
    before :each do
      create(:file, name:'file')
      create(:question, name: 'quest')
    end
=end
    it 'should call the right method with right values' do
      #QuestionnaireHelper.should_receive(:get_questions_from_csv)
      allow(session[:user])
      post 'import'
      expect(response).to redirect_to(import_file_path)
      #response.should render_template(edit_questionnaire)
    end
  end

  describe '#export' do
    it 'should call export method'
    #Questionnaire.should_receive(:to_csv).with()
    post 'export'
    response.should redirect_to(Questionnaire)
  end
end