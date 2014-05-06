require File.dirname(__FILE__) + '/../test_helper'

class LanguageTest < ActiveSupport::TestCase
  fixtures :languages

  # Replace this with your real tests.
  def test_create_languages
    @language1 = Language.new
    @language1.name= "Spanish"
    assert @language1.save
  end

  def test_update_languages
    @language1 = Language.find(languages(:first).id)
    @language1.name= "Spanish"
    @language1.save
    @language1.reload
    assert_equal "Spanish", @language1.name
  end

  def test_delete_languages
    @language1 = Language.new
    @language1.name= "Spanish"
    @language1.save
    @language1.delete
    begin
      @language1 = Language.find(@language1.id)
    rescue
      assert true
      return
    end
    assert false
    return
  end

end
