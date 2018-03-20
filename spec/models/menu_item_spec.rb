describe MenuItem do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  describe '.find_or_create_by_name' do
    it 'returns a menu item with corresponding name'
    # Write your test here!
  end

  describe '#delete' do
    it 'deletes current menu items and all child menu items'
    # Write your test here!
  end

  describe '#above' do
    context 'when current menu item has parent_id' do
      it 'returns the first parent menu item by querying the parent_id and current sequence number minus one'
      # Write your test here!
    end

    context 'when current menu item does not have parent_id' do
      it 'returns the first parent menu item by querying the current sequence number minus one'
      # Write your test here!
    end
  end

  describe '#below' do
    context 'when current menu item has parent_id' do
      it 'returns the first parent menu item by querying the parent_id and current sequence number plus one'
      # Write your test here!
    end

    context 'when current menu item does not have parent_id' do
      it 'returns the first parent menu item by querying the current sequence number plus one'
      # Write your test here!
    end
  end

  describe '.repack' do
    context 'when current menu item has repack_id' do
      it 'finds all menus items with parent_id equal to repack_id and repacks the sequence number'
      # Write your test here!
    end

    context 'when current menu item does not have repack_id' do
      it 'finds all menus items with parent_id null and repacks the sequence number'
      # Write your test here!
    end
  end

  describe '.next_seq' do
    context 'when parent_id is bigger than 0' do
      it 'selects corresponding menu items with inputted parent_id and returns the next sequence number'
      # Write your test here!
    end

    context 'when parent_id is smaller than or equal to 0' do
      it 'selects corresponding menu items with parent_id null and returns the next sequence number'
      # Write your test here!
    end
  end

  describe '.items_for_permissions' do
    context 'when inputted variable (permission_ids) is nil' do
      context 'when the controller_action_id of current item is bigger than 0' do
        context 'when perms does not exist' do
          it 'returns corresponding items'
          # Write your test here!
        end
      end

      context 'when the controller_action_id of current item is smaller than or equal to 0 and the content_page_id of current item is bigger than 0' do
        context 'when perms does not exist' do
          it 'returns corresponding items'
          # Write your test here!
        end
      end

      context 'when the controller_action_id and content_page_id of current item is smaller than or equal to 0' do
        it 'returns corresponding items'
        # Write your test here!
      end
    end

    context 'when inputted variable (permission_ids) is not nil' do
      context 'when the controller_action_id of current item is bigger than 0' do
        context 'when perms exists' do
          it 'returns corresponding items'
          # Write your test here!
        end
      end

      context 'when the controller_action_id of current item is smaller than or equal to 0 and the content_page_id of current item is bigger than 0' do
        context 'when perms exists' do
          it 'returns corresponding items'
          # Write your test here!
        end
      end

      context 'when the controller_action_id and content_page_id of current item is smaller than or equal to 0' do
        it 'returns corresponding items'
        # Write your test here!
      end
    end
  end
end
