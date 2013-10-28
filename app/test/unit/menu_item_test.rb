require File.dirname(__FILE__) + '/../test_helper'

class MenuItemTest < ActiveSupport::TestCase
  
  #test that name must always be present for a menu
  def test_name
    m = MenuItem.new
    assert !m.save
  end
  
  def test_duplicate_name
    m = MenuItem.new
    m.name = "Menu1"
    m.save
    m1 = MenuItem.new
    m1.name = m.name
    assert !m1.save
  end
  
  def test_delete
    m = MenuItem.new
    m.name = "menu1"
    m.save
    
    m.delete
    
    m = MenuItem.find_by_name("menu1")
    assert_nil m
  end
  
  def test_next_seq
    assert_equal 1, MenuItem.next_seq(nil)
  end
end
