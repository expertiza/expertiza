describe AdviceController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
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
    context "when invalid_advice? is called with item advice score > max score of itemnaire" do
      # max score of advice = 3 (!=2)
      let(:itemAdvice1) {build(:item_advice, id:1, score: 1, item_id: 1, advice: "Advice1")}
      let(:itemAdvice2) {build(:item_advice, id:2, score: 3, item_id: 1, advice: "Advice2")}
      let(:itemnaire) do
        build(:itemnaire, id: 1, min_item_score: 1,
          items: [build(:item, id: 1, weight: 2, item_advices: [itemAdvice1,itemAdvice2])], max_item_score: 2)
      end

      it "invalid_advice? returns true when called with incorrect maximum score for a item advice" do
        sorted_advice = itemnaire.items[0].item_advices.sort_by { |x| x.score }.reverse
        num_advices = itemnaire.max_item_score - itemnaire.min_item_score + 1          
        controller.instance_variable_set(:@itemnaire,itemnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,itemnaire.items[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with item advice score < min score of itemnaire" do
      # min score of advice = 0 (!=1)
      let(:itemAdvice1) {build(:item_advice, id:1, score: 0, item_id: 1, advice: "Advice1")}
      let(:itemAdvice2) {build(:item_advice, id:2, score: 2, item_id: 1, advice: "Advice2")}
      let(:itemnaire) do
        build(:itemnaire, id: 1, min_item_score: 1,
          items: [build(:item, id: 1, weight: 2, item_advices: [itemAdvice1,itemAdvice2])], max_item_score: 2)
      end

      it "invalid_advice? returns true when called with incorrect minimum score for a item advice" do
        sorted_advice = itemnaire.items[0].item_advices.sort_by { |x| x.score }.reverse
        num_advices = itemnaire.max_item_score - itemnaire.min_item_score + 1         
        controller.instance_variable_set(:@itemnaire,itemnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,itemnaire.items[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with number of advices > (max-min) score of itemnaire" do
      # number of advices > 2
      let(:itemAdvice1) {build(:item_advice, id:1, score: 1, item_id: 1, advice: "Advice1")}
      let(:itemAdvice2) {build(:item_advice, id:2, score: 2, item_id: 1, advice: "Advice2")}
      let(:itemAdvice3) {build(:item_advice, id:3, score: 2, item_id: 1, advice: "Advice3")}
      let(:itemnaire) do
        build(:itemnaire, id: 1, min_item_score: 1,
          items: [build(:item, id: 1, weight: 2, item_advices: [itemAdvice1,itemAdvice2,itemAdvice3])], max_item_score: 2)
      end

      it "invalid_advice? returns true when called with incorrect number of item advices" do
        sorted_advice = itemnaire.items[0].item_advices.sort_by { |x| x.score }.reverse
        num_advices = itemnaire.max_item_score - itemnaire.min_item_score + 1         
        controller.instance_variable_set(:@itemnaire,itemnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,itemnaire.items[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with no advices for a item in itemnaire" do
      # 0 advices - empty list scenario
      let(:itemnaire) do
        build(:itemnaire, id: 1, min_item_score: 1,
          items: [build(:item, id: 1, weight: 2, item_advices: [])], max_item_score: 2)
      end

      it "invalid_advice? returns true when called with an empty advice list " do
        sorted_advice = itemnaire.items[0].item_advices.sort_by { |x| x.score }.reverse
        num_advices = itemnaire.max_item_score - itemnaire.min_item_score + 1         
        controller.instance_variable_set(:@itemnaire,itemnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,itemnaire.items[0])).to eq(true)
      end
    end

    context "when invalid_advice? is called with all conditions satisfied" do
      # Question Advices passing all conditions
      let(:itemAdvice1) {build(:item_advice, id:1, score: 1, item_id: 1, advice: "Advice1")}
      let(:itemAdvice2) {build(:item_advice, id:2, score: 2, item_id: 1, advice: "Advice2")}
      let(:itemnaire) do
        build(:itemnaire, id: 1, min_item_score: 1,
          items: [build(:item, id: 1, weight: 2, item_advices: [itemAdvice1,itemAdvice2])], max_item_score: 2)
      end

      it "invalid_advice? returns false when called with all correct pre-conditions " do
        sorted_advice = itemnaire.items[0].item_advices.sort_by { |x| x.score }.reverse
        num_advices = itemnaire.max_item_score - itemnaire.min_item_score + 1         
        controller.instance_variable_set(:@itemnaire,itemnaire)
        expect(controller.invalid_advice?(sorted_advice,num_advices,itemnaire.items[0])).to eq(false)
      end
    end
  end

  describe '#edit_advice' do

    context "when edit_advice is called and invalid_advice? evaluates to true" do
      # edit advice called
      let(:itemAdvice1) {build(:item_advice, id:1, score: 1, item_id: 1, advice: "Advice1")}
      let(:itemAdvice2) {build(:item_advice, id:2, score: 2, item_id: 1, advice: "Advice2")}
      let(:itemnaire) do
        build(:itemnaire, id: 1, min_item_score: 1,
          items: [build(:item, id: 1, weight: 2, item_advices: [itemAdvice1,itemAdvice2])], max_item_score: 2)
      end

      it "edit advice redirects correctly when called" do
        allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire)
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
      let(:itemAdvice1) {build(:item_advice, id:1, score: 1, item_id: 1, advice: "Advice1")}
      let(:itemAdvice2) {build(:item_advice, id:2, score: 2, item_id: 1, advice: "Advice2")}
      let(:itemnaire) do
        build(:itemnaire, id: 1, min_item_score: 1,
          items: [build(:item, id: 1, weight: 2, item_advices: [itemAdvice1,itemAdvice2])], max_item_score: 2)
      end
      
      it "saves advice successfully" do
        # When an advice is saved successfully
        allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire)
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
        allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire)
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