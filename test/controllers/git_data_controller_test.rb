require 'test_helper'

class GitDataControllerTest < ActionController::TestCase
  setup do
    @git_datum = git_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:git_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create git_datum" do
    assert_difference('GitDatum.count') do
      post :create, git_datum: { additions: @git_datum.additions, author: @git_datum.author, commits: @git_datum.commits, date: @git_datum.date, deletions: @git_datum.deletions, files: @git_datum.files, pull_request: @git_datum.pull_request }
    end

    assert_redirected_to git_datum_path(assigns(:git_datum))
  end

  test "should show git_datum" do
    get :show, id: @git_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @git_datum
    assert_response :success
  end

  test "should update git_datum" do
    patch :update, id: @git_datum, git_datum: { additions: @git_datum.additions, author: @git_datum.author, commits: @git_datum.commits, date: @git_datum.date, deletions: @git_datum.deletions, files: @git_datum.files, pull_request: @git_datum.pull_request }
    assert_redirected_to git_datum_path(assigns(:git_datum))
  end

  test "should destroy git_datum" do
    assert_difference('GitDatum.count', -1) do
      delete :destroy, id: @git_datum
    end

    assert_redirected_to git_data_path
  end
end
