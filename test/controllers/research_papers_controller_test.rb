require 'test_helper'

class ResearchPapersControllerTest < ActionController::TestCase
  setup do
    @research_paper = research_papers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:research_papers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create research_paper" do
    assert_difference('ResearchPaper.count') do
      post :create, research_paper: { author_id: @research_paper.author_id, conference: @research_paper.conference, date: @research_paper.date, name: @research_paper.name, topic: @research_paper.topic }
    end

    assert_redirected_to research_paper_path(assigns(:research_paper))
  end

  test "should show research_paper" do
    get :show, id: @research_paper
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @research_paper
    assert_response :success
  end

  test "should update research_paper" do
    patch :update, id: @research_paper, research_paper: { author_id: @research_paper.author_id, conference: @research_paper.conference, date: @research_paper.date, name: @research_paper.name, topic: @research_paper.topic }
    assert_redirected_to research_paper_path(assigns(:research_paper))
  end

  test "should destroy research_paper" do
    assert_difference('ResearchPaper.count', -1) do
      delete :destroy, id: @research_paper
    end

    assert_redirected_to research_papers_path
  end
end
