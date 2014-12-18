class MenuItem < ActiveRecord::Base

  attr_accessor :controller_action, :content_page

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.find_or_create_by_name (params)
    MenuItem.find_or_create_by(name: params)
  end

  def delete
    children = MenuItem.where(['parent_id = ?',self.id])
    children.each {|child| child.delete }
    self.destroy
  end

  def above
    if self.parent_id
      conditions =
        ["parent_id = ? and seq = ?", self.parent_id, self.seq - 1]
    else
      conditions =
        ["parent_id is null and seq = ?", self.seq - 1]
    end

    return MenuItem.where(conditions).first
  end


  def below
    if self.parent_id
      conditions =
        ["parent_id = ? and seq = ?", self.parent_id, self.seq + 1]
    else
      conditions =
        ["parent_id is null and seq = ?", self.seq + 1]
    end

    return MenuItem.where(conditions).first
  end


  def MenuItem.repack(repack_id)
    if repack_id
      items = MenuItem.where("parent_id = #{repack_id}").order('seq')
    else
      items = MenuItem.where("parent_id is null").order('seq')
    end

    seq = 1
    for item in items do
      item.seq = seq
      item.save!
      seq += 1
    end
  end


  def MenuItem.next_seq(parent_id)
    if parent_id and parent_id.to_i > 0
      next_seq = MenuItem.find_by_sql("select coalesce(max(seq) + 1, 1) as seq from menu_items where parent_id = #{parent_id}")
    else
      next_seq = MenuItem.find_by_sql("select coalesce(max(seq) + 1, 1) as seq from menu_items where parent_id is null")
    end

    if next_seq
      return next_seq[0].seq
    else
      return 1
    end
  end


  def MenuItem.items_for_permissions(permission_ids = nil)
    # Hash for faster & easier lookups
    if permission_ids
      perms = {}
      for id in permission_ids do
        perms[id] = true
      end
    end

    # List of items to return
    items = []

    menu_items = self.all.order('parent_id, seq, id')
    for item in menu_items do
      if item.controller_action_id.to_i > 0
        item.controller_action =
          ControllerAction.find(item.controller_action_id)
        if perms
          if perms.has_key?(item.controller_action.effective_permission_id)
            items << item
          end
        else
          items << item
        end
      elsif item.content_page_id.to_i > 0
        item.content_page =
          ContentPage.find(item.content_page_id)
        if perms
          if perms.has_key?(item.content_page.permission_id)
            items << item
          end
        else
          items << item
        end
      end
    end

    return items
  end

end
