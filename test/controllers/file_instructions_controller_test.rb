require 'test_helper'

class FileInstructionsControllerTest < ActionController::TestCase
  setup do
    @file_instruction = file_instructions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:file_instructions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create file_instruction" do
    assert_difference('FileInstruction.count') do
      post :create, file_instruction: { file_type: @file_instruction.file_type, host_url: @file_instruction.host_url, instructions: @file_instruction.instructions }
    end

    assert_redirected_to file_instruction_path(assigns(:file_instruction))
  end

  test "should show file_instruction" do
    get :show, id: @file_instruction
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @file_instruction
    assert_response :success
  end

  test "should update file_instruction" do
    patch :update, id: @file_instruction, file_instruction: { file_type: @file_instruction.file_type, host_url: @file_instruction.host_url, instructions: @file_instruction.instructions }
    assert_redirected_to file_instruction_path(assigns(:file_instruction))
  end

  test "should destroy file_instruction" do
    assert_difference('FileInstruction.count', -1) do
      delete :destroy, id: @file_instruction
    end

    assert_redirected_to file_instructions_path
  end
end
