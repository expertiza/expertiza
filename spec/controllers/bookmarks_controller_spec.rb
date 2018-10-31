require 'spec_helper'
require 'rails_helper'

describe BookmarksController do
  render_views

  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true,
                       participants: [build(:participant)], teams: [build(:assignment_team)],
                       course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student, id: 42) }
  let(:topic) { build(:topic) }
  let(:bookmark) { build(:bookmark) }
  let(:bookmarkrating) { build(:bookmarkrating) }
  let(:participant) { build(:participant) }
  let(:participant_review) { build(:participant_review) }


  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
    allow(Bookmark).to receive(:where).and_return([bookmark])
    allow(Bookmark).to receive(:where).and_return([bookmark])
    @session = {user: student}
    stub_current_user(student, student.role.name, student.role)
    @request.session[:user] = student
  #  @current_user=student
  end

  describe '#list' do
    context 'when student requests for bookmarks' do
      it 'should show bookmarks' do
        params = {id: '1'}
        get :list, params, @session
        expect(controller.instance_variable_get(:@bookmarks).size).to eq(1)
        expect(controller.instance_variable_get(:@topic).topic_name).to eq('Hello world!')
        expect(response.body).to include '<td>This is a test topic</td>'
        expect(response.body).to include '<td><a href=http://test.com target=\'_blank\'>Test</td>'
        expect(response.body.match(%r{<td>\s+-\s+<\/td>}m)).to be_truthy
      end
    end
  end


  describe '#action_allowed?' do
    context 'when params action is list, new, create for student' do

      context 'when the role name of current user is student' do

        it 'allows certain action list ' do
          controller.params = {action: 'list'}
          expect(controller.send(:action_allowed?)).to be true
        end
        it 'allows certain action new ' do
          controller.params = {action: 'new'}
          expect(controller.send(:action_allowed?)).to be true
        end
        it 'allows certain action create ' do
          controller.params = {action: 'create'}
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end

    context 'when params action is list, new, create for role other than student' do

      context 'when the role name of current user is not student' do

        it 'do not allow  action list ' do
          controller.params = {action: 'list'}
          stub_current_user(instructor, instructor.role.name, instructor.role)
          expect(controller.send(:action_allowed?)).to be false
        end
        it 'do not allow  action new ' do
          controller.params = {action: 'new'}
          stub_current_user(ta, ta.role.name, ta.role)
          expect(controller.send(:action_allowed?)).to be false
        end
        it 'do not allow action create ' do
          controller.params = {action: 'create'}
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end
    context 'when params action is edit, update, destroy for role student' do

      context 'when the bookmark was added by the same student' do
        before(:each) do
          allow(Bookmark).to receive(:find).with(1).and_return(bookmark)
          @request.session[:user] = student
        end
        it 'allows action edit ' do
          controller.params  = {id: '1', action:'edit'}
          expect(controller.send(:action_allowed?)).to be true

        end
        it 'allows action update ' do
          controller.params  = {id: '1', action: 'update'}
          expect(controller.send(:action_allowed?)).to be true

        end
        it 'allows action destroy' do
          controller.params  = {id: '1',  action:'destroy'}
          expect(controller.send(:action_allowed?)).to be true

        end

        end
    end

  end


  context "#create" do
    before(:each) do
      allow(Bookmark).to receive(:find).with(1).and_return(bookmark)
    end
    it 'when bookmark is saved successfully' do

      session = {user: student}
      params = {
          url: 'https://google.com',
          title: 'Google Test',
          description: 'Use Google',
          user_id: student.id,
          topic_id: bookmark.topic_id

      }
      post :create, params, session
      #allow_any_instance_of(Bookmark).to receive(:undo_link).with('The user "chenzy@gmail.com" has been successfully created. ').and_return(true)
      expect(flash[:success]).to eq "Your bookmark has been successfully created!"
      expect(response).to redirect_to('http://test.host/bookmarks/list?id='+params[:topic_id].to_s)
    end



    it 'when bookmark is not saved successfully' do

      session = {user: student}
      params = {
          url: 'https://google.com',
          title: 'Google Test',
          description: 'Use Google',
          user_id: student.id,
          topic_id: bookmark.topic_id

      }

      post :create, params, session
      expect(lambda{ expect_any_instance_of(Bookmark).to receive(:create).and_return( raise StandardError )}).to redirect_to('http://test.host/bookmarks/list?id='+params[:topic_id].to_s)
    end
  end

  context '#update' do
    before(:each) do
      allow(Bookmark).to receive(:find).with(1).and_return(bookmark)
    end

    it 'when bookmark is updated successfully' do
      params = {
         bookmark: { url: 'https://google.com',
          title: 'Google Test',
          description: 'Use Google',
          user_id: student.id,
          topic_id: bookmark.topic_id
         },
         id: 1


      }

      post :update, params,session
      expect(flash[:success]).to eq 'Your bookmark has been successfully updated!'
      expect(response).to redirect_to('http://test.host/bookmarks/list?id='+bookmark.topic_id.to_s)
    end
    it 'when bookmark is not updated successfully' do
        params = {
          bookmark: {
                      title: 'Google Test',
                      description: 'Use Google',
                      user_id: student.id,
                      topic_id: bookmark.topic_id
          },
          id: 1


      }
      post :update, params, session
      expect(flash[:success]).not_to eq 'Your bookmark has been successfully updated!'
      expect(response).to redirect_to('http://test.host/bookmarks/list?id='+bookmark.topic_id.to_s)
    end
  end

  context '#destroy' do
    it 'when bookmark is deleted successfully' do
      allow(Bookmark).to receive(:find).with(1).and_return(bookmark)
      @params = {id: 1}
      get :destroy, @params, session
      expect(flash[:success]).not_to be_nil
      expect(response).to redirect_to('http://test.host/bookmarks/list?id='+bookmark.topic_id.to_s)
    end
  end

  context '#save_bookmark_rating_score' do
    it 'when bookmark Rating is updated successfully' do
      allow(Bookmark).to receive(:find).with(1).and_return(bookmark)
      allow(BookmarkRating).to receive(:where).and_return([bookmarkrating])
      @params = {id:1,rating: 5}
      get :save_bookmark_rating_score, @params, session
      expect(response).to redirect_to('http://test.host/bookmarks/list?id='+bookmark.topic_id.to_s)
    end
  end
 context '#new_bookmark_review' do
    it 'when Bookmark Rating is updated successfully' do
         allow(Bookmark).to receive(:find).with(1).and_return(bookmark)

     allow(AssignmentParticipant).to receive(:find_by).with({:user_id=>42}).and_return(participant_review)

      @params = {id:1}
      get :new_bookmark_review, @params, session
      expect(response).to redirect_to('http://test.host/response/new?id='+@params[:id].to_s+'&return=bookmark')

    end
  end



end
