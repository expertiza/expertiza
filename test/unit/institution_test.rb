<<<<<<< HEAD
<<<<<<< HEAD
require File.dirname(__FILE__) + '/../test_helper'

class InstitutionTest < ActiveSupport::TestCase
  fixtures :institutions
  
  def setup
    @institution = institutions(:institution0)
  end
  
  def test_create
    assert_kind_of Institution, @institution
    assert_equal institutions(:institution0).id, @institution.id
    assert_equal "North Carolina State University", @institution.name
  end
  
  def test_update
    assert_equal "North Carolina State University", @institution.name
    @institution.name = "Computer science"
    @institution.save
    @institution.reload
    assert_equal "Computer science", @institution.name
  end
  
  def test_destroy
    @institution.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Institution.find(@institution.id) }
  end
  
=======
require File.dirname(__FILE__) + '/../test_helper'

class InstitutionTest < ActiveSupport::TestCase
  fixtures :institutions
  
  def setup
    @institution = institutions(:institution0)
  end
  
  def test_create
    assert_kind_of Institution, @institution
    assert_equal institutions(:institution0).id, @institution.id
    assert_equal "North Carolina State University", @institution.name
  end
  
  def test_update
    assert_equal "North Carolina State University", @institution.name
    @institution.name = "Computer science"
    @institution.save
    @institution.reload
    assert_equal "Computer science", @institution.name
  end
  
  def test_destroy
    @institution.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Institution.find(@institution.id) }
  end
  
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
require File.dirname(__FILE__) + '/../test_helper'

class InstitutionTest < ActiveSupport::TestCase
  fixtures :institutions
  
  def setup
    @institution = institutions(:institution0)
  end
  
  def test_create
    assert_kind_of Institution, @institution
    assert_equal institutions(:institution0).id, @institution.id
    assert_equal "North Carolina State University", @institution.name
  end
  
  def test_update
    assert_equal "North Carolina State University", @institution.name
    @institution.name = "Computer science"
    @institution.save
    @institution.reload
    assert_equal "Computer science", @institution.name
  end
  
  def test_destroy
    @institution.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Institution.find(@institution.id) }
  end
  
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end