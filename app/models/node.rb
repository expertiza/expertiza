# Base Node class
# Provides common method definitions, but minimal functoinality.
# Must be subclassed for use in tree_display code
#
# Author: AJBUDLON
# Date: 7/18/2008
class Node < ApplicationRecord
  has_paper_trail
  # acts_as_nested_set

  belongs_to :parent, class_name: 'Node', foreign_key: 'parent_id', inverse_of: false
  has_many :children, class_name: 'Node', foreign_key: 'parent_id', dependent: :nullify, inverse_of: false

  # Retrieves the nodes of this type
  def self.get(_sortvar = nil, _sortorder = nil, _user_id = nil, _show = nil, _parent_id = nil, _search = nil); end

  # Retrieves the children of this node
  def get_children(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, search = nil); end

  # Retrieves the action partial for this node
  def get_partial_name
    self.class.table + '_actions'
  end

  # Most objects are not leaves
  # Currently only assignment and questionnaire are a leaf
  # type node
  def is_leaf
    false
  end

  # Retrieves the corresponding model for the
  # node's object type
  def self.table; end

  # Retrieves the node's object name
  def get_name; end

  # Retrieves the node's object directory
  def get_directory; end

  # Retrieves the node's object create_at
  def get_creation_date; end

  # Retrieves the node's object create_at
  def get_modified_date; end

  # Retrieves the type of children this node has
  def get_child_type; end
end
