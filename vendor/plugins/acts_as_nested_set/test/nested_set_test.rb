require 'test/unit'

require 'rubygems'
require 'active_record'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

class Mixin < ActiveRecord::Base
end

class NestedSet < Mixin
  acts_as_nested_set :scope => "root_id IS NULL"

  def self.table_name() "mixins" end
end

class NestedSetWithStringScope < Mixin
  acts_as_nested_set :scope => 'root_id = #{root_id}'

  def self.table_name() "mixins" end
end

class NestedSetWithSymbolScope < Mixin
  acts_as_nested_set :scope => :root

  def self.table_name() "mixins" end
end

class NestedSetSuperclass < Mixin
  acts_as_nested_set :scope => :root

  def self.table_name() "mixins" end
end

class NestedSetSubclass < NestedSetSuperclass
end


class MixinNestedSetTest < Test::Unit::TestCase

  def setup
    ActiveRecord::Schema.define(:version => 1) do
      create_table :mixins do |t|
        t.integer :pos, :parent_id, :lft, :rgt, :root_id
        t.timestamps
      end
    end

    (1..10).each { |counter| NestedSet.create! }

    [ [0,  1, 10, NestedSetSuperclass],
      [11, 2, 5, NestedSetSubclass],
      [12, 3, 4, NestedSetSuperclass],
      [11, 6, 9, NestedSetSuperclass],
      [13, 7, 8, NestedSetSubclass]
    ].each do |sti|
      sti[3].create! :parent_id => sti[0], :lft => sti[1], :rgt => sti[2], :root_id => 3100
    end

    [ [0,  1, 20],
      [16, 2, 7],
      [17, 3, 4],
      [17, 5, 6],
      [16, 14, 13],
      [20, 9, 10],
      [20, 11, 12],
      [16, 8, 19],
      [23, 15, 16],
      [23, 17, 18]
    ].each do |set|
      NestedSetWithStringScope.create! :parent_id => set[0], :lft => set[1], :rgt => set[2], :root_id => 42
    end
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_mixing_in_methods
    ns = NestedSet.new
    assert(ns.respond_to?(:all_children))
    assert_equal(ns.scope_condition, "root_id IS NULL")
    check_method_mixins ns
  end

  def test_string_scope
    ns = NestedSetWithStringScope.new
    ns.root_id = 1
    assert_equal(ns.scope_condition, "root_id = 1")
    ns.root_id = 42
    assert_equal(ns.scope_condition, "root_id = 42")
    check_method_mixins ns
  end

  def test_symbol_scope
    ns = NestedSetWithSymbolScope.new
    ns.root_id = 1
    assert_equal(ns.scope_condition, "root_id = 1")
    ns.root_id = 42
    assert_equal(ns.scope_condition, "root_id = 42")
    check_method_mixins ns
  end

  def check_method_mixins(obj)
    [:scope_condition, :left_col_name, :right_col_name, :parent_column, :root?, :add_child,
    :children_count, :full_set, :all_children, :direct_children].each { |symbol| assert(obj.respond_to?(symbol)) }
  end

  def set(id)
    NestedSet.find(id)
  end

  def test_adding_children
    assert(set(1).unknown?)
    assert(set(2).unknown?)
    set(1).add_child set(2)

    # Did we maintain adding the parent_ids?
    assert(set(1).root?)
    assert(set(2).child?)
    assert(set(2).parent_id == set(1).id)

    # Check boundies
    assert_equal(set(1).lft, 1)
    assert_equal(set(2).lft, 2)
    assert_equal(set(2).rgt, 3)
    assert_equal(set(1).rgt, 4)

    # Check children cound
    assert_equal(set(1).children_count, 1)

    set(1).add_child set(3)

    #check boundries
    assert_equal(set(1).lft, 1)
    assert_equal(set(2).lft, 2)
    assert_equal(set(2).rgt, 3)
    assert_equal(set(3).lft, 4)
    assert_equal(set(3).rgt, 5)
    assert_equal(set(1).rgt, 6)

    # How is the count looking?
    assert_equal(set(1).children_count, 2)

    set(2).add_child set(4)

    # boundries
    assert_equal(set(1).lft, 1)
    assert_equal(set(2).lft, 2)
    assert_equal(set(4).lft, 3)
    assert_equal(set(4).rgt, 4)
    assert_equal(set(2).rgt, 5)
    assert_equal(set(3).lft, 6)
    assert_equal(set(3).rgt, 7)
    assert_equal(set(1).rgt, 8)

    # Children count
    assert_equal(set(1).children_count, 3)
    assert_equal(set(2).children_count, 1)
    assert_equal(set(3).children_count, 0)
    assert_equal(set(4).children_count, 0)

    set(2).add_child set(5)
    set(4).add_child set(6)

    assert_equal(set(2).children_count, 3)


    # Children accessors
    assert_equal(set(1).full_set.length, 6)
    assert_equal(set(2).full_set.length, 4)
    assert_equal(set(4).full_set.length, 2)

    assert_equal(set(1).all_children.length, 5)
    assert_equal(set(6).all_children.length, 0)

    assert_equal(set(1).direct_children.length, 2)

  end

   def test_snipping_tree
     big_tree = NestedSetWithStringScope.find(16)

     # Make sure we have the right one
     assert_equal(3, big_tree.direct_children.length)
     assert_equal(10, big_tree.full_set.length)
     assert_equal [17, 23, 20], big_tree.direct_children.map(&:id)

     NestedSetWithStringScope.find(20).destroy

     big_tree = NestedSetWithStringScope.find(16)

     assert_equal(9, big_tree.full_set.length)
     assert_equal(2, big_tree.direct_children.length)

     assert_equal(1, NestedSetWithStringScope.find(16).lft)
     assert_equal(2, NestedSetWithStringScope.find(17).lft)
     assert_equal(3, NestedSetWithStringScope.find(18).lft)
     assert_equal(4, NestedSetWithStringScope.find(18).rgt)
     assert_equal(5, NestedSetWithStringScope.find(19).lft)
     assert_equal(6, NestedSetWithStringScope.find(19).rgt)
     assert_equal(7, NestedSetWithStringScope.find(17).rgt)
     assert_equal(8, NestedSetWithStringScope.find(23).lft)
     assert_equal(15, NestedSetWithStringScope.find(24).lft)
     assert_equal(16, NestedSetWithStringScope.find(24).rgt)
     assert_equal(17, NestedSetWithStringScope.find(25).lft)
     assert_equal(18, NestedSetWithStringScope.find(25).rgt)
     assert_equal(19, NestedSetWithStringScope.find(23).rgt)
     assert_equal(20, NestedSetWithStringScope.find(16).rgt)
   end
 
   def test_deleting_root
     NestedSetWithStringScope.find(16).destroy
     assert_equal 15, NestedSetWithStringScope.count
   end

   def test_common_usage
     NestedSet.find(1).add_child(NestedSet.find(2))
     assert_equal(1, NestedSet.find(1).direct_children.length)

     NestedSet.find(2).add_child(NestedSet.find(3))
     assert_equal(1, NestedSet.find(1).direct_children.length) 

     # Local cache is now out of date!
     # Problem: the update_alls update all objects up the tree
     assert_equal(2, NestedSet.find(1).all_children.length)

     assert_equal(1, NestedSet.find(1).lft)
     assert_equal(2, NestedSet.find(2).lft)
     assert_equal(3, NestedSet.find(3).lft)
     assert_equal(4, NestedSet.find(3).rgt)
     assert_equal(5, NestedSet.find(2).rgt)
     assert_equal(6, NestedSet.find(1).rgt)

     assert(NestedSet.find(1).root?)

     begin
       NestedSet.find(4).add_child(NestedSet.find(1))
       fail
     rescue
     end

     assert_equal(2, NestedSet.find(1).all_children.length)

     NestedSet.find(1).add_child NestedSet.find(4)

     assert_equal(3, NestedSet.find(1).all_children.length)
   end
 
   def test_inheritance
     parent = NestedSetWithStringScope.find(11)
     child = NestedSetWithStringScope.find(12)
     grandchild = NestedSetWithStringScope.find(13)
     assert_equal 5, parent.full_set.size
     assert_equal 2, child.full_set.size
     assert_equal 4, parent.all_children.size
     assert_equal 1, child.all_children.size
     assert_equal 2, parent.direct_children.size
     assert_equal 1, child.direct_children.size
     child.destroy
     assert_equal 3, parent.full_set.size
   end
 
end
