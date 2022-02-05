describe MenuItem do
  ###
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###
  let!(:test1) { create(:menu_item, name: 'home1', parent_id: nil,  seq: 1) }
  let!(:test2) { create(:menu_item, name: 'home2', parent_id: 1,    seq: 2) }
  let!(:test3) { create(:menu_item, name: 'home3', parent_id: 1,    seq: 3) }
  let!(:test4) { create(:menu_item, name: 'home4', parent_id: 1,    seq: 4) }
  let!(:test5) { create(:menu_item, name: 'home5', parent_id: nil,  seq: 2) }
  let!(:test6) { create(:menu_item, name: 'home6', parent_id: nil,  seq: 5) }
  (1..3).each do |i|
    let!("controller_action#{i}".to_sym) { ControllerAction.create(site_controller_id: i, name: 'name', permission_id: 1) }
    let!("content_page#{i}".to_sym) { ContentPage.create(title: "home page#{i}", name: "home#{i}", content: '', permission_id: i, content_cache: '') }
  end

  describe '.find_or_create_by_name' do
    it 'returns a menu item with corresponding name' do
      expect(MenuItem.find_or_create_by_name('home').name).to eq('home')
    end
  end

  describe '#delete' do
    it 'deletes current menu items and all child menu items' do
      expect { test1.delete }.to change { MenuItem.count }.from(6).to(2)
      expect { test6.delete }.to change { MenuItem.count }.from(2).to(1)
    end
  end

  describe '#above' do
    context 'when current menu item has parent_id' do
      it 'returns the first parent menu item by querying the parent_id and current sequence number minus one' do
        expect(test4.above).to eq(test3)
      end
    end

    context 'when current menu item does not have parent_id' do
      it 'returns the first parent menu item by querying the current sequence number minus one' do
        expect(test5.above).to eq(test1)
      end
    end
  end

  describe '#below' do
    context 'when current menu item has parent_id' do
      it 'returns the first parent menu item by querying the parent_id and current sequence number plus one' do
        expect(test3.below).to eq(test4)
      end
    end

    context 'when current menu item does not have parent_id' do
      it 'returns the first parent menu item by querying the current sequence number plus one' do
        expect(test1.below).to eq(test5)
      end
    end
  end

  describe '.repack' do
    context 'when current menu item has repack_id' do
      it 'finds all menus items with parent_id equal to repack_id and repacks the sequence number' do
        MenuItem.repack(1)
        test2.reload
        test3.reload
        test4.reload
        expected_seq = [1, 2, 3]
        expect([test2.seq, test3.seq, test4.seq]).to eq(expected_seq)
      end
    end

    context 'when current menu item does not have repack_id' do
      it 'finds all menus items with parent_id null and repacks the sequence number' do
        MenuItem.repack(nil)
        test1.reload
        test5.reload
        test6.reload
        expected_seq = [1, 2, 3]
        expect([test1.seq, test5.seq, test6.seq]).to eq(expected_seq)
      end
    end
  end

  describe '.next_seq' do
    context 'when parent_id is bigger than 0' do
      it 'selects corresponding menu items with inputted parent_id and returns the next sequence number' do
        expect(MenuItem.next_seq(1)).to eq(5)
      end
    end

    context 'when parent_id is smaller than or equal to 0' do
      it 'selects corresponding menu items with parent_id null and returns the next sequence number' do
        expect(MenuItem.next_seq(nil)).to eq(6)
      end
    end
  end

  describe '.items_for_permissions' do
    context 'when inputted variable (permission_ids) is nil' do
      context 'when the controller_action_id of current item is bigger than 0' do
        context 'when perms does not exist' do
          it 'returns corresponding items' do
            test1.update_attributes(controller_action_id: 1, content_page_id: nil)
            test2.update_attributes(controller_action_id: 2, content_page_id: nil)
            test3.update_attributes(controller_action_id: 3, content_page_id: nil)
            expected_items = [test1, test2, test3]
            expect(MenuItem.items_for_permissions).to eq(expected_items)
          end
        end
      end

      context 'when the controller_action_id of current item is smaller than or equal to 0 and the content_page_id of current item is bigger than 0' do
        context 'when perms does not exist' do
          it 'returns corresponding items' do
            test1.update_attributes(controller_action_id: nil, content_page_id: 1)
            test2.update_attributes(controller_action_id: nil, content_page_id: 2)
            test3.update_attributes(controller_action_id: nil, content_page_id: 3)
            expected_items = [test1, test2, test3]
            expect(MenuItem.items_for_permissions).to eq(expected_items)
          end
        end
      end

      context 'when the controller_action_id and content_page_id of current item is smaller than or equal to 0' do
        it 'returns corresponding items' do
          expect(MenuItem.items_for_permissions).to be_empty
        end
      end
    end

    context 'when inputted variable (permission_ids) is not nil' do
      context 'when the controller_action_id of current item is bigger than 0' do
        context 'when perms exists' do
          it 'returns corresponding items' do
            test1.update_attributes(controller_action_id: 1, content_page_id: nil)
            test2.update_attributes(controller_action_id: 2, content_page_id: nil)
            test3.update_attributes(controller_action_id: 3, content_page_id: nil)
            expected_items = [test1, test2, test3]
            items = MenuItem.items_for_permissions([1])
            expect(items).to eq(expected_items)
          end
        end
      end

      context 'when the controller_action_id of current item is smaller than or equal to 0 and the content_page_id of current item is bigger than 0' do
        context 'when perms exists' do
          it 'returns corresponding items' do
            test1.update_attributes(controller_action_id: nil, content_page_id: 1)
            test2.update_attributes(controller_action_id: nil, content_page_id: 2)
            test3.update_attributes(controller_action_id: nil, content_page_id: 3)
            expected_items = [test1]
            items = MenuItem.items_for_permissions([1])
            expect(items).to eq(expected_items)
          end
        end
      end

      context 'when the controller_action_id and content_page_id of current item is smaller than or equal to 0' do
        it 'returns corresponding items' do
          expect(MenuItem.items_for_permissions([1])).to be_empty
        end
      end
    end
  end
end
