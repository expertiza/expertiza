describe Assignment do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 3, name: 'no one') }
  let(:review_response_map) { build(:review_response_map, response: [response], reviewer: build(:participant), reviewee: build(:assignment_team)) }
  let(:teammate_review_response_map) { build(:review_response_map, type: 'TeammateReviewResponseMap') }
  let(:participant) { build(:participant, id: 1) }
  let(:question) { double('Question') }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:response) { build(:response) }
  let(:course) { build(:course) }
  let(:assignment_due_date) do
    build(:assignment_due_date, due_at: '2011-11-11 11:11:11 UTC', deadline_name: 'Review',
                                description_url: 'https://expertiza.ncsu.edu/', round: 1)
  end
  let(:topic_due_date) { build(:topic_due_date, deadline_name: 'Submission', description_url: 'https://github.com/expertiza/expertiza') }
  describe '.max_outstanding_reviews' do
    it 'returns 2 by default' do
      expect(Assignment.max_outstanding_reviews).to equal(2)
    end
  end
  describe '#team_assignment?' do
    it 'checks an assignment has team' do
      # @assignment = build(:assignment)
      expect(assignment.team_assignment).to eql(true)
    end
  end
  # Need to create assignment, else giving error
  describe '#topics?' do
    context 'when sign_up_topics array is not empty' do
      it 'says current assignment has topics' do
        @assignment = create(:assignment)
        expect(@assignment.sign_up_topics.empty?).to eql(true)
        @topic = create(:topic,assignment: @assignment)
        # or @topic.assignment = @assignment
        expect(@assignment.sign_up_topics.empty?).to eql(false)
      end
    end
    context 'when sign_up_topics array is empty' do
      it 'says current assignment does not have a topic' do
        # @assignment = create(:assignment)
        expect(assignment.sign_up_topics.empty?).to eql(true)
      end
    end
  end
  # Ask guide -> Build not working in this case
  describe '.set_courses_to_assignment' do
    it 'fetches all courses belong to current instructor and with the order of course names' do
      # @instructor = create(:instructor)
      # @assignment = create(:assignment, instructor: @instructor)
      @course1 = create(:course, instructor: instructor, name: 'C')
      @cours2 = create(:course, instructor: instructor, name: 'B')
      @cours3 = create(:course, instructor: instructor, name: 'A')
      # expect(Assignment.set_courses_to_assignment(@instructor).map {|x| x.name}).to be_an_instance_of(Array)
      @arr = Assignment.set_courses_to_assignment(instructor).map {|x| x.name}
      expect(@arr).to match_array(['A','B','C'])
    end
  end
  describe '#teams?' do
    context 'when teams array is not empty' do
      it 'says current assignment has teams' do
        # assignment=create(:assignment)
        # expect(assignment.teams.empty?).to equal(true)
        # team=create(:assignment_team)
        # team.parent_id=assignment.id
        expect(assignment.teams.empty?).to equal(false)
      end
    end
    context 'when sign_up_topics array is empty' do
      it 'says current assignment does not have a team' do
        assignment=build(:assignment)
        expect(assignment.teams.empty?).to equal(true)
      end
    end
  end
  describe '#valid_num_review' do
    context 'when num_reviews_allowed is not -1 and num_reviews_allowed is less than num_reviews_required' do
      it 'adds an error message to current assignment object' do
        # Check error
        # @assignment = create(:assignment)
        assignment.num_reviews_allowed = 2
        assignment.num_reviews_required = 3
        expect(assignment.num_reviews_allowed < assignment.num_reviews_required).to eql(!assignment.has_attribute?(:message))
      end
    end
    context 'when the first if condition is false, num_metareviews_allowed is not -1, and num_metareviews_allowed less than num_metareviews_required' do
      it 'adds an error message to current assignment object' do
        @assignment = create(:assignment)
        @assignment.num_reviews_allowed = 4
        @assignment.num_reviews_required = 3
        @assignment.num_metareviews_allowed = 2
        @assignment.num_metareviews_required = 3
        expect(@assignment.num_metareviews_allowed < @assignment.num_metareviews_required).to eql(!@assignment.has_attribute?(:message))
      end
    end
  end
  describe '#assign_metareviewer_dynamically' do
    it 'returns true when assigning successfully' do
      @assignment = create(:assignment)
      @assignment_participant = create(:participant, assignment: @assignment)
      @assignment.review_mappings << review_response_map
      expect(@assignment.assign_metareviewer_dynamically(@assignment_participant)).to be_an_instance_of(MetareviewResponseMap)
    end
  end
  describe '#response_map_to_metareview' do
    it 'does not raise any errors and returns the first review response map' do
      @assignment=create(:assignment)
      @participant=create(:participant,assignment:@assignment)
      #@review_response_map=create(:review_response_map,assignment:@assignment)
      @meta_review_response_map=create(:meta_review_response_map,review_mapping:review_response_map,reviewee:@participant)
      @assignment.review_mappings << review_response_map
      expect(@assignment.response_map_to_metareview(@participant)).to eq(review_response_map)
    end
  end
  describe '#metareview_mappings' do
    it 'returns review mapping' do
      @assignment=create(:assignment)
      @participant=create(:participant,assignment:@assignment)
      #@review_response_map=create(:review_response_map,assignment:@assignment)
      @meta_review_response_map=create(:meta_review_response_map,review_mapping:review_response_map,reviewee:@participant)
      @assignment.review_mappings << review_response_map
      expect(@assignment.metareview_mappings.first).to eq(@meta_review_response_map)
    end
  end
  describe '#dynamic_reviewer_assignment?' do
    context 'when review_assignment_strategy of current assignment is Auto-Selected' do
      it 'returns true' do
        # @assignment = create(:assignment)
        expect(assignment.review_assignment_strategy).to eql('Auto-Selected')
      end
    end
    context 'when review_assignment_strategy of current assignment is Instructor-Selected' do
      it 'returns false' do
        # @assignment = create(:assignment)
        expect(assignment.review_assignment_strategy=='Instructor-Selected').to eql(false)
      end
    end
  end
  # Take guidance from guide
  # describe '#scores' do
  #   context 'when assignment is varying rubric by round assignment' do
  #     it 'calculates scores in each round of each team in current assignment' do 
  #       # @assignment = create(:assignment,id: 999)
  #       # @review_response_map = create(:review_response_map)
  #       # @participant=create(:participant,:assignment => @assignment)
  #       @questionnaire = create(:questionnaire)
  #       @assignment_questionnaire = create(:assignment_questionnaire, assignment: @assignment, used_in_round: 2, questionnaire: @questionnaire)
  #       @questions = create(:question, questionnaire: @questionnaire)
  #       expect(assignment.scores(@questions)).to eql(10)
  #     end
  #   end
  #   context 'when assignment is not varying rubric by round assignment' do
  #     it 'calculates scores of each team in current assignment'
  #   end
  # end
  describe '#path' do
    context 'when both course_id and instructor_id are nil' do
      it 'raises an error' do
        # assignment=create(:assignment)
        assignment.course_id= nil
        assignment.instructor_id= nil
        expect{assignment.path}.to raise_error(RuntimeError,"The path cannot be created. The assignment must be associated with either a course or an instructor.")
      end
    end
    context 'when course_id is not nil and course_id is larger than 0' do
      it 'returns path with course directory path' do
        # assignment=create(:assignment)
        assignment.course_id= 1
        expect(assignment.path).to be == "#{Rails.root}/pg_data/instructor6/csc517/test/final_test"
      end
    end
    context 'when course_id is nil' do
      it 'returns path without course directory path' do
        # assignment=create(:assignment)
        assignment.course_id=nil
        expect(assignment.path).to be == "#{Rails.root}/pg_data/instructor6/final_test"
      end
     end
  end
  describe '#check_condition' do
    context 'when the next due date is nil' do
      it 'returns false ' do
        # assignment=create(:assignment)
        # dead_rigth=create(:deadline_right)
        # ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
        #ass_due_date=AssignmentDueDate.where(:parent_id => assignment.id).first
        # ass_due_date.due_at= DateTime.now.in_time_zone - 1.day
        expect(assignment.check_condition(:id)).to equal(false)
      end
    end
    # Changing to build gives active record not found error
    context 'when the next due date is allowed to review submissions' do
      it 'returns true' do
        # assignment=create(:assignment)
        dead_rigth=create(:deadline_right ,:name=> 'OK')
        #dead_rigth.id=3
        #dead_rigth.name='OK'
        ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
        #ass_due_date=AssignmentDueDate.where(:parent_id => assignment.id).first
        #ass_due_date.due_at= DateTime.now.in_time_zone - 1.day
        expect(assignment.check_condition(:id)).to equal(true) 
      end
    end
  end
  describe '#submission_allowed' do
    it 'returns true when the next topic due date is allowed to submit sth'do
      # assignment=create(:assignment)
      dead_rigth=create(:deadline_right ,:name=> 'OK')
      ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)        
      expect(assignment.submission_allowed).to equal (true)
    end
  end
  describe '#quiz_allowed' do
    it 'returns false when the next topic due date is not allowed to do quiz' do
      # assignment=create(:assignment)
      dead_rigth=create(:deadline_right ,:name=> 'NO')
      ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)        
      expect(assignment.submission_allowed).to equal (false)    
    end  
  end
  describe '#can_review' do
    it "returns false when the next assignment due date is not allowed to review other's work" do
      # assignment=create(:assignment)
      dead_rigth=create(:deadline_right ,:name=> 'NO')
      ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)        
      expect(assignment.submission_allowed).to equal (false)
    end
  end
  describe '#metareview_allowed' do
    it 'returns true when the next assignment due date is not allowed to do metareview' do
      # assignment=create(:assignment)
      dead_rigth=create(:deadline_right ,:name=> 'NO')
      ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)        
      expect(!assignment.submission_allowed).to equal (true)
    end
  end
  # Does not work without create
  describe '#delete' do
    context 'when there is at least one review response in current assignment' do
      it 'raises an error messge and current assignment cannot be deleted' do
        @assignment = create(:assignment)
        @review_response_map = create(:review_response_map, assignment: @assignment)
        expect{@assignent.delete}.to raise_error(NoMethodError,'undefined method `delete\' for nil:NilClass')
      end
    end
    context 'when there is no review response in current assignment and at least one teammate review response in current assignment' do
      it 'raises an error messge and current assignment cannot be deleted' do
        @assignment = create(:assignment)
        @assignment_team = create(:assignment_team, assignment: @assignment)
        @team_user = create(:team_user,team: @assignment_team)
        expect{@assignent.delete}.to raise_error(NoMethodError,'undefined method `delete\' for nil:NilClass')
      end
    end
    context 'when ReviewResponseMap and TeammateReviewResponseMap can be deleted successfully' do
      it 'deletes other corresponding db records and current assignment' do
        # @assignment = create(:assignment)
        # @assignment_team = create(:assignment_team, assignment: @assignment)
        # @team_user = create(:team_user,team: @assignment_team)
        expect(!assignment.delete.blank?).to eql(true)
      end
    end
  end
  describe '#microtask?' do
    context 'when microtask is not nil' do
      it 'returns microtask status (false by default)' do
          assignment = build(:assignment, microtask: true)
          # assignment = create(:assignment)
          expect(assignment.microtask?).to eql(true)
      end 
    end
    context 'when microtask is nil' do
      it 'returns false' do
          assignment = build(:assignment, microtask: nil)
          expect(assignment.microtask?).to eql(false)
      end
    end
  end
  describe '#add_participant' do
    context 'when user is nil' do
      it 'raises an error' do
          # @assignment = create(:assignment)
          expect{assignment.add_participant('',true,true,true)}.to raise_error(NoMethodError)
      end
    end

    # Get undefined method 'url_for' if we dont use create
    context 'when the user is already a participant of current assignment' do
      it 'raises an error' do
          @assignment = create(:assignment)
          @user = create(:student)
          @participant = create(:participant, user: @user)
          expect{@assignment.add_participant(@user.name,true,true,true)}.to raise_error(RuntimeError)
      end
    end

    context 'when AssignmentParticipant was created successfully' do
      it 'returns true' do
        @assignment = create(:assignment)
        @user = create(:student)
        expect(assignment.add_participant(@user.name,true,true,true)).to eql(true)
      end
    end
  end

  describe '#create_node' do
    it 'will save node' do
      # @assignment = create(:assignment)
      expect(assignment.create_node).to eql(true)
    end
  end

  describe '#number_of_current_round' do
    context 'when next_due_date is nil' do
      it 'returns 0' do
        # @assignment = create(:assignment)
        expect(assignment.number_of_current_round(nil)).to eql(0)
      end
    end

    # Create is required here also
    context 'when next_due_date is not nil' do
      it 'returns the round of next_due_date' do
        @assignment = create(:assignment)
        @deadline_right = create(:deadline_right)
        @assignment_due_date = create(:assignment_due_date, assignment: @assignment, parent_id: @deadline_right.id, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id)
        @assignment_due_date.due_at = DateTime.now.in_time_zone + 1.day
        expect(@assignment.number_of_current_round(nil)>0).to eql(true)
      end
    end
  end


  #Active record mysql record not unique error
  describe '#current_stage_name' do
   context 'when assignment has staggered deadline' do
      context 'topic_id is nil' do
        it 'returns Unknow' do
          assignment = create(:assignment, staggered_deadline: true)
          expect(assignment.current_stage_name(nil)).to eql("Unknown")
        end
      end

      context 'topic_id is not nil' do
        it 'returns Unknow' do
          assignment = create(:assignment, staggered_deadline: true)
          @topic = create(:topic, assignment: assignment )
          expect(assignment.current_stage_name(@topic.id)).to eql("Finished")
        end
      end
    end

    context 'when assignment does not have staggered deadline' do
      context "when due date is not equal to 'Finished', due date is not nil and its deadline name is not nil" do
        it 'returns the deadline name of current due date' do
             assignment = create(:assignment, staggered_deadline: false)
              dead_rigth = create(:deadline_right)
              ass_due_date = create(:assignment_due_date,deadline_name: 'submission', :parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
              expect(assignment.current_stage_name(nil)).to eql(ass_due_date.deadline_name.to_s)
        end 
      end
    end
  end
  describe '#microtask?' do
    it 'checks whether assignment is a micro task' do
      assignment = build(:assignment, microtask: true)
      expect(assignment.microtask?).to equal(true)
    end
  end
  describe '#varying_rubrics_by_round?' do
    it 'returns true if the number of 2nd round questionnaire(s) is larger or equal 1' do
      assignment = create(:assignment)
      questionnaire = create(:questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, assignment: assignment, questionnaire: questionnaire , used_in_round: 2)
      expect(assignment.varying_rubrics_by_round?).to eq(true)
      end
  end
  
  describe '#link_for_current_stage' do
    context 'when current assignment has staggered deadline and topic id is nil' do
      it 'returns nil' do
        assignment = create( :assignment, staggered_deadline: true )
        expect(assignment.link_for_current_stage(nil)).to eq(nil)
      end
    end
    context 'when current assignment does not have staggered deadline' do
      context 'when due date is a TopicDueDate' do
        it 'returns nil' do
          assignment = create( :assignment, staggered_deadline: false)
          dead_rigth = create(:deadline_right)
          assignment_due_date = create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id,)
          expect(assignment.link_for_current_stage).to eq(nil)
        end
      end
      context 'when due_date is not nil, not finished and is not a TopicDueDate' do
        it 'returns description url of current due date' do
          assignment = create(:assignment, staggered_deadline: false)
          dead_rigth = create(:deadline_right)
          ass_due_date = create(:assignment_due_date, due_at: DateTime.now.in_time_zone + 1.day, :parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
           expect(assignment.link_for_current_stage).to eql(ass_due_date.description_url)
        end
      end
    end
  end
  describe '#stage_deadline' do
    context 'when topic id is nil and current assignment has staggered deadline' do
      it 'returns Unknown' do
        # assignment=create(:assignment)
        assignment.staggered_deadline=true
        expect(assignment.stage_deadline()).to eq("Unknown")  
      end
    end
    context 'when current assignment does not have staggered deadline' do
      context 'when due date is nil' do
        it 'returns nil' do
          # assignment=create(:assignment)
          # dead_rigth=create(:deadline_right)
          # ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id,:due_at=> DateTime.now.in_time_zone - 1.day)
          #ass_due_date.due_at= DateTime.now.in_time_zone - 1.day
          expect(assignment.stage_deadline).not_to be_nil    
        end
      end

      # We do require create over here
      context 'when due date is not nil and due date is not equal to Finished' do
        it 'returns due date' do
          # assignment=create(:assignment)
          dead_rigth=create(:deadline_right)
          ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
          #ass_due_date.due_at= DateTime.now.in_time_zone - 1.day
          expect(assignment.stage_deadline).to eq(ass_due_date.due_at.to_s)
        end
      end
    end
  end

  # We need create here 
  describe '#num_review_rounds' do
    it 'returns max round number in all due dates of current assignment' do
      # assignment=create(:assignment)
      dead_rigth=create(:deadline_right)
      create(:assignment_due_date,:round=>1,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
      create(:assignment_due_date,:round=>2,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
      create(:assignment_due_date,:round=>3,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
      expect(assignment.num_review_rounds).to equal(3) 
    end
  end

  describe '#find_current_stage' do
    context 'when next due date is nil' do
      it 'returns Finished'do
        # assignment=create(:assignment)
        dead_rigth=create(:deadline_right)
        ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id,:due_at=> DateTime.now.in_time_zone - 1.day)
        expect(assignment.find_current_stage()).to eq("Finished")
      end
    end

    context 'when next due date is nil' do
      it 'returns next due date object' do
        assignment=create(:assignment)
        dead_rigth=create(:deadline_right)
        ass_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id)
        expect(assignment.find_current_stage()).to eq(ass_due_date) 
      end
    end
  end

  # MySql error if create not used
  describe '#review_questionnaire_id' do
    it 'returns review_questionnaire_id' do
      @assignment = create(:assignment)
      @questionnaire = create(:questionnaire)
      @assignment_questionnaire = create(:assignment_questionnaire, assignment:@assignment, questionnaire: @questionnaire)
      expect(@assignment.review_questionnaire_id>0).to eql(true)
    end
  end

  describe 'has correct csv values?' do
    before(:each) do
      create(:assignment)
      create(:assignment_team, name: 'team1')
      @student = create(:student, name: 'student1')
      create(:participant, user: @student)
      create(:questionnaire)
      create(:question)
      create(:review_response_map)
      create(:response)
      @options = {'team_id' => 'true', 'team_name' => 'true',
                  'reviewer' => 'true', 'question' => 'true',
                  'question_id' => 'true', 'comment_id' => 'true',
                  'comments' => 'true', 'score' => 'true'}
    end

    def generated_csv(t_assignment, t_options)
      delimiter = ','
      CSV.generate(col_sep: delimiter) do |csv|
        csv << Assignment.export_headers(t_assignment.id)
        csv << Assignment.export_details_fields(t_options)
        Assignment.export_details(csv, t_assignment.id, t_options)
      end
    end

    it 'checks_if_csv has the correct data' do
      create(:answer, comments: 'Test comment')
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with some options' do
      create(:answer, comments: 'Test comment')
      @options['team_id'] = 'false'
      @options['question_id'] = 'false'
      @options['comment_id'] = 'false'
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_some_options_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with no data' do
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_data_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with data and no options' do
      create(:answer, comments: 'Test comment')
      @options['team_id'] = 'false'
      @options['team_name'] = 'false'
      @options['reviewer'] = 'false'
      @options['question'] = 'false'
      @options['question_id'] = 'false'
      @options['comment_id'] = 'false'
      @options['comments'] = 'false'
      @options['score'] = 'false'
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_options_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end
  end

  describe 'find_due_dates' do
    context 'if deadline is of assignment' do
      it ' return assignment due_date' do
        assignment = create(:assignment)
        dead_rigth=create(:deadline_right)
        @deadline_type = create(:deadline_type)  
        @assignment_due_date=create(:assignment_due_date,:parent_id => assignment.id,:review_allowed_id=>dead_rigth.id,:review_of_review_allowed_id=>dead_rigth.id,:submission_allowed_id=>dead_rigth.id,deadline_type:@deadline_type)
        expect(assignment.find_due_dates("submission").first).to eq(@assignment_due_date)
      end
    end

    context 'if deadline is of assignment' do
      it ' return assignment nil' do
        assignment = create(:assignment)
        expect(assignment.find_due_dates("submission").first).to eq(nil)
      end
    end
  end
end
