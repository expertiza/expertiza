describe AdviceController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, username: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }

  describe '#action_allowed?' do
    context 'when the role of current user is Super-Admin' do
      # Checking for Super-Admin
      it 'allows certain action' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Instructor' do
      # Checking for Instructor
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Student' do
      # Checking for Student
      it 'refuses certain action' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end

  describe '#invalid_advice?' do
    context "when invalid_advice? is called with question advice score > max score of questionnaire" do
      # max score of advice = 3 (!=2)
      let(:questionAdvice1) {build(:question_advice, id:1, score: 1, question_id: 1, advice: "Advice1")}
      let(:questionAdvice2) {build(:question_advice, id:2, score: 3, question_id: 1, advice: "Advice2")}
      let(:questionnaire) do
        build(:questionnaire, id: 1, min_question_score: 1,
          questions: [build(:question, id: 1, weight: 2, question_advices: [questionAdvice1,questionAdvice2])], max_question_score: 2)
      end

      it "invalid_advice? returns true when called with incorrect maximum score for a question advice" do
        sorted_advice = questionnaire.questions[0].question_advices.sort_by { |x| x.score }.reverse
        num_advices = questionnaire.max_question_score - questionnaire.min_question_score + 1          
        controller.instance_variable_set(:@questionnaire,questionnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,questionnaire.questions[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with question advice score < min score of questionnaire" do
      # min score of advice = 0 (!=1)
      let(:questionAdvice1) {build(:question_advice, id:1, score: 0, question_id: 1, advice: "Advice1")}
      let(:questionAdvice2) {build(:question_advice, id:2, score: 2, question_id: 1, advice: "Advice2")}
      let(:questionnaire) do
        build(:questionnaire, id: 1, min_question_score: 1,
          questions: [build(:question, id: 1, weight: 2, question_advices: [questionAdvice1,questionAdvice2])], max_question_score: 2)
      end

      it "invalid_advice? returns true when called with incorrect minimum score for a question advice" do
        sorted_advice = questionnaire.questions[0].question_advices.sort_by { |x| x.score }.reverse
        num_advices = questionnaire.max_question_score - questionnaire.min_question_score + 1         
        controller.instance_variable_set(:@questionnaire,questionnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,questionnaire.questions[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with number of advices > (max-min) score of questionnaire" do
      # number of advices > 2
      let(:questionAdvice1) {build(:question_advice, id:1, score: 1, question_id: 1, advice: "Advice1")}
      let(:questionAdvice2) {build(:question_advice, id:2, score: 2, question_id: 1, advice: "Advice2")}
      let(:questionAdvice3) {build(:question_advice, id:3, score: 2, question_id: 1, advice: "Advice3")}
      let(:questionnaire) do
        build(:questionnaire, id: 1, min_question_score: 1,
          questions: [build(:question, id: 1, weight: 2, question_advices: [questionAdvice1,questionAdvice2,questionAdvice3])], max_question_score: 2)
      end

      it "invalid_advice? returns true when called with incorrect number of question advices" do
        sorted_advice = questionnaire.questions[0].question_advices.sort_by { |x| x.score }.reverse
        num_advices = questionnaire.max_question_score - questionnaire.min_question_score + 1         
        controller.instance_variable_set(:@questionnaire,questionnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,questionnaire.questions[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with no advices for a question in questionnaire" do
      # 0 advices - empty list scenario
      let(:questionnaire) do
        build(:questionnaire, id: 1, min_question_score: 1,
          questions: [build(:question, id: 1, weight: 2, question_advices: [])], max_question_score: 2)
      end

      it "invalid_advice? returns true when called with an empty advice list " do
        sorted_advice = questionnaire.questions[0].question_advices.sort_by { |x| x.score }.reverse
        num_advices = questionnaire.max_question_score - questionnaire.min_question_score + 1         
        controller.instance_variable_set(:@questionnaire,questionnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,questionnaire.questions[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with all conditions satisfied" do
      # Question Advices passing all conditions
      let(:questionAdvice1) {build(:question_advice, id:1, score: 1, question_id: 1, advice: "Advice1")}
      let(:questionAdvice2) {build(:question_advice, id:2, score: 2, question_id: 1, advice: "Advice2")}
      let(:questionnaire) do
        build(:questionnaire, id: 1, min_question_score: 1,
          questions: [build(:question, id: 1, weight: 2, question_advices: [questionAdvice1,questionAdvice2])], max_question_score: 2)
      end

      it "invalid_advice? returns false when called with all correct pre-conditions " do
        sorted_advice = questionnaire.questions[0].question_advices.sort_by { |x| x.score }.reverse
        num_advices = questionnaire.max_question_score - questionnaire.min_question_score + 1         
        controller.instance_variable_set(:@questionnaire,questionnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,questionnaire.questions[0])).to eq(false)
      end
    end
  end

  describe '#edit_advice' do

    context "when edit_advice is called and invalid_advice? evaluates to true" do
      # edit advice called
      let(:questionAdvice1) {build(:question_advice, id:1, score: 1, question_id: 1, advice: "Advice1")}
      let(:questionAdvice2) {build(:question_advice, id:2, score: 2, question_id: 1, advice: "Advice2")}
      let(:questionnaire) do
        build(:questionnaire, id: 1, min_question_score: 1,
          questions: [build(:question, id: 1, weight: 2, question_advices: [questionAdvice1,questionAdvice2])], max_question_score: 2)
      end

      it "edit advice redirects correctly when called" do
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        params = {id: 1}
        session = {user: instructor1}
        result = get :edit_advice, params: params, session: session
        expect(result.status).to eq 200
        expect(result).to render_template(:edit_advice)
      end
    end
  end

  describe '#save_advice' do
    context "when save_advice is called" do
      # When ad advice is saved
      let(:questionAdvice1) {build(:question_advice, id:1, score: 1, question_id: 1, advice: "Advice1")}
      let(:questionAdvice2) {build(:question_advice, id:2, score: 2, question_id: 1, advice: "Advice2")}
      let(:questionnaire) do
        build(:questionnaire, id: 1, min_question_score: 1,
          questions: [build(:question, id: 1, weight: 2, question_advices: [questionAdvice1,questionAdvice2])], max_question_score: 2)
      end
      
      it "saves advice successfully" do
        # When an advice is saved successfully
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        allow(QuestionAdvice).to receive(:update).with('1',{:advice => "Hello"}).and_return("Ok")
        params = {advice: {"1" => {:advice => "Hello"}}, id: 1}
        session = {user: instructor1}
        result = get :save_advice, params: params, session: session
        expect(flash[:notice]).to eq('The advice was successfully saved!')
        expect(result.status).to eq 302
        expect(result).to redirect_to('/advice/edit_advice?id=1')
      end

      it "does not save the advice" do
        # When an advice is not saved
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        allow(QuestionAdvice).to receive(:update).with(any_args).and_return("Ok")
        params = {id: 1}
        session = {user: instructor1}
        result = get :save_advice, params: params, session: session
        expect(flash[:notice]).not_to be_present
        expect(result.status).to eq 302
        expect(result).to redirect_to('/advice/edit_advice?id=1')
      end
    end
  end
end