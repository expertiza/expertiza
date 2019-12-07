describe 'late policies' do
  subject { LatePolicy.create(:id => 1, :policy_name => 'Policy Name', :instructor_id => 4, :max_penalty => 30, :penalty_per_unit => 10, :penalty_unit => 5) }


  it "is valid with valid attributes" do
    subject.instructor_id = 4
    expect(subject).to be_valid
  end

  it "is not valid without a policy name" do
    subject.policy_name = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without an instructor" do
    subject.instructor_id = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a max penalty" do
    subject.max_penalty = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without penalty per unit" do
    subject.penalty_per_unit = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without penalty unit" do
    subject.penalty_unit = nil
    expect(subject).to_not be_valid
  end

  it "should allow valid values for max penalty" do
    (1..49).to_a.each do |v|
      should allow_value(v).for(:max_penalty)
    end
  end

  it "should allow valid values for penalty per unit" do
    expect(subject.penalty_per_unit).to be > 0
  end

  describe "#check_policy_with_same_name" do
    context "when name is same and instructor is same" do
      before :each do
        latePolicy = LatePolicy.new
        latePolicy.policy_name="Policy Name"
        latePolicy.max_penalty=40
        latePolicy.penalty_per_unit=30
        latePolicy.instructor_id=4
        allow(LatePolicy).to receive(:where).with(any_args).and_return([latePolicy])
      end
      it "should return true" do
        expect(LatePolicy.check_policy_with_same_name('Policy Name', 4)).eql? true
      end
    end
    context "when name is different and instructor is same" do
      before :each do
        latePolicy = LatePolicy.new
        latePolicy.policy_name="Policy Name"
        latePolicy.max_penalty=40
        latePolicy.penalty_per_unit=30
        latePolicy.instructor_id=4
        allow(LatePolicy).to receive(:where).with({policy_name: 'Policy Name'}).and_return([latePolicy])
      end
      it "should return false" do
        expect(LatePolicy.check_policy_with_same_name('Policy Name', 4)).eql? false
      end
    end
  end
end