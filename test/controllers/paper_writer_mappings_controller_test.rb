require 'test_helper'

class PaperWriterMappingsControllerTest < ActionController::TestCase
  setup do
    @paper_writer_mapping = paper_writer_mappings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:paper_writer_mappings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create paper_writer_mapping" do
    assert_difference('PaperWriterMapping.count') do
      post :create, paper_writer_mapping: { paper_id: @paper_writer_mapping.paper_id, writer_id: @paper_writer_mapping.writer_id }
    end

    assert_redirected_to paper_writer_mapping_path(assigns(:paper_writer_mapping))
  end

  test "should show paper_writer_mapping" do
    get :show, id: @paper_writer_mapping
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @paper_writer_mapping
    assert_response :success
  end

  test "should update paper_writer_mapping" do
    patch :update, id: @paper_writer_mapping, paper_writer_mapping: { paper_id: @paper_writer_mapping.paper_id, writer_id: @paper_writer_mapping.writer_id }
    assert_redirected_to paper_writer_mapping_path(assigns(:paper_writer_mapping))
  end

  test "should destroy paper_writer_mapping" do
    assert_difference('PaperWriterMapping.count', -1) do
      delete :destroy, id: @paper_writer_mapping
    end

    assert_redirected_to paper_writer_mappings_path
  end
end
