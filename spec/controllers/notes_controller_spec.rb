require 'rails_helper'
describe NotesController do
  it "should get notes index" do
    get note_url
    assert_response :success
  end

  it "should create note" do
    assert_difference('note.count') do
      post note_url, params: {note: @note}
    end

    assert_redirected_to note_path(Article.last)
    assert_equal 'note was successfully created.', flash[:notice]
  end

  it "should update note" do
    note = note(:one)
    patch note_url(note), params: {article: {title: "updated"}}
    assert_redirected_to note_path(note)
    note.reload
    assert_equal 'note was successfully created.', flash[:notice]
  end

  it "should destroy note" do
    assert_difference 'note.count', -1 do
      delete note_url(@note)
    end

    assert_redirected_to note_path
  end
end