require 'test_helper'

class InstitutionTest < Test::Unit::TestCase
  fixtures :institutions
  
  def setup
    @institution = Institution.find(1)
  end
  
  def test_create
    assert_kind_of Institution, @institution
    assert_equal 1, @institution.id
    assert_equal "Computer Science", @institution.name
  end
  
  def test_update
    assert_equal "Computer Science", @institution.name
    @institution.name = "Computer science"
    @institution.save
    @institution.reload
    assert_equal "Computer science", @institution.name
  end
  
  def test_destroy
    @institution.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Institution.find(@institution.id) }
  end
  
end