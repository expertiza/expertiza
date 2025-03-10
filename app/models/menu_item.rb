class MenuItem < ApplicationRecord
  attr_accessor :controller_action, :content_page

  validates :name, presence: true
  validates :name, uniqueness: true

  def self.find_or_create_by_name(params)
    MenuItem.find_or_create_by(name: params)
  end

  def delete
    children = MenuItem.where('parent_id = ?', id)
    children.each(&:delete)
    destroy
  end

  def above
    conditions = if parent_id
                   ['parent_id = ? and seq = ?', parent_id, seq - 1]
                 else
                   ['parent_id is null and seq = ?', seq - 1]
                 end

    # MenuItem.where(conditions).first
    MenuItem.find_by(conditions)
  end

  def below
    conditions = if parent_id
                   ['parent_id = ? and seq = ?', parent_id, seq + 1]
                 else
                   ['parent_id is null and seq = ?', seq + 1]
                 end

    # MenuItem.where(conditions).first
    MenuItem.find_by(conditions)
  end

  def self.repack(repack_id)
    items = if repack_id
              MenuItem.where('parent_id = ?', repack_id).order('seq')
            else
              MenuItem.where('parent_id is null').order('seq')
            end

    seq = 1
    items.each do |item|
      item.seq = seq
      item.save!
      seq += 1
    end
  end

  def self.next_seq(parent_id)
    next_seq = if parent_id.to_i > 0
                 MenuItem.select('coalesce(max(seq) + 1, 1) as seq').where(parent_id: parent_id)
               else
                 MenuItem.select('coalesce(max(seq) + 1, 1) as seq').where('parent_id is null')
               end
    next_seq ? next_seq[0].seq : 1
  end

  def self.items_for_permissions(permission_ids = nil)
    if permission_ids
      perms = {}
      permission_ids.each { |id| perms[id] = true }
    end
    # List of items to return
    items = []
    menu_items = all.order('parent_id, seq, id')
    menu_items.each do |item|
      if item.controller_action_id.to_i > 0
        item.controller_action = ControllerAction.find(item.controller_action_id)
        if perms
          items << item if perms.key?(item.controller_action.effective_permission_id)
        else
          items << item
        end
      elsif item.content_page_id.to_i > 0
        item.content_page = ContentPage.find(item.content_page_id)
        if perms
          items << item if perms.key?(item.content_page.permission_id)
        else
          items << item
        end
      end
    end
    items
  end
end
