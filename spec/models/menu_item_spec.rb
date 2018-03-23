describe MenuItem do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  before(:each) do
    @test1 = MenuItem.new(name: "home1", parent_id: nil, seq: 1, controller_action_id: nil, content_page_id: nil, label: "newlabel")
    @test1.save
    @test2 = MenuItem.new(name: "home2", parent_id: 1, seq: 2, controller_action_id: nil, content_page_id: nil, label: "newlabel")
    @test2.save
    @test3 = MenuItem.new(name: "home3", parent_id: 1, seq: 3, controller_action_id: nil, content_page_id: nil, label: "newlabel")
    @test3.save
    @test4 = MenuItem.new(name: "home4", parent_id: 1, seq: 4, controller_action_id: nil, content_page_id: nil, label: "newlabel")
    @test4.save
    @test5 = MenuItem.new(name: "home5", parent_id: nil, seq: 2, controller_action_id: nil, content_page_id: nil, label: "newlabel")
    @test5.save
    @test6 = MenuItem.new(name: "home6", parent_id: nil, seq: 5, controller_action_id: nil, content_page_id: nil, label: "newlabel")
    @test6.save
    @controller_action1 = ControllerAction.new(site_controller_id: 1, name: "render1", permission_id: 1)
    @controller_action1.save
    @controller_action2 = ControllerAction.new(site_controller_id: 2, name: "render2", permission_id: 1)
    @controller_action2.save
    @controller_action3 = ControllerAction.new(site_controller_id: 3, name: "render3", permission_id: 2)
    @controller_action3.save
    @content_page1 = ContentPage.new(title: "home page1", name: "home1", content: "this has something1", permission_id: 1, content_cache: "this has something1")
    @content_page1.save
    @content_page2 = ContentPage.new(title: "home page2", name: "home2", content: "this has something2", permission_id: 2, content_cache: "this has something2")
    @content_page2.save
    @content_page3 = ContentPage.new(title: "home page3", name: "home3", content: "this has something3", permission_id: 3, content_cache: "this has something3")
    @content_page3.save
  end


  describe '.find_or_create_by_name' do
    it 'returns a menu item with corresponding name' do
    # Write your test here!
      expect(MenuItem.find_or_create_by_name("home").name).to eq("home")
    end
  end

  describe '#delete' do
    it 'deletes current menu items and all child menu items' do
    # Write your test here!
            expect{@test1.delete}.to change{MenuItem.count}.by(-4)
    end
  end

  describe '#above' do
    context 'when current menu item has parent_id' do
      it 'returns the first parent menu item by querying the parent_id and current sequence number minus one' do
      # Write your test here!
        expect(@test4.above).to eq(@test3)
      end
    end

    context 'when current menu item does not have parent_id' do
      it 'returns the first parent menu item by querying the current sequence number minus one' do
      # Write your test here!
        expect(@test5.above).to eq(@test1) 
      end
    end
  end

  describe '#below' do
    context 'when current menu item has parent_id' do
      it 'returns the first parent menu item by querying the parent_id and current sequence number plus one' do
      # Write your test here!
        expect(@test3.below).to eq(@test4)
      end
    end

    context 'when current menu item does not have parent_id' do
      it 'returns the first parent menu item by querying the current sequence number plus one' do
      # Write your test here!
        expect(@test1.below).to eq(@test5) 
      end
    end
  end

  describe '.repack' do
    context 'when current menu item has repack_id' do
      it 'finds all menus items with parent_id equal to repack_id and repacks the sequence number' do
      # Write your test here!
	@temp = MenuItem.repack(1)
	@test2.reload
	@test3.reload
	@test4.reload
	expected_seq = [1,2,3]
	expect([@test2.seq, @test3.seq, @test4.seq]).to eq(expected_seq)
      end
    end

    context 'when current menu item does not have repack_id' do
      it 'finds all menus items with parent_id null and repacks the sequence number' do
      # Write your test here!
	@temp = MenuItem.repack(nil)
	@test1.reload
	@test5.reload
	@test6.reload
	expected_seq = [1,2,3]
	expect([@test1.seq, @test5.seq, @test6.seq]).to eq(expected_seq)
      end
    end
  end

  describe '.next_seq' do
    context 'when parent_id is bigger than 0' do
      it 'selects corresponding menu items with inputted parent_id and returns the next sequence number' do
      # Write your test here!
        expect(MenuItem.next_seq(1)).to eq(5)
      end
    end

    context 'when parent_id is smaller than or equal to 0' do
      it 'selects corresponding menu items with parent_id null and returns the next sequence number' do
      # Write your test here!
        expect(MenuItem.next_seq(nil)).to eq(6)
      end
    end
  end

  describe '.items_for_permissions' do
    context 'when inputted variable (permission_ids) is nil' do
      context 'when the controller_action_id of current item is bigger than 0' do
        context 'when perms does not exist' do
          it 'returns corresponding items' do
          # Write your test here!
            @test7 = MenuItem.new(name: "home7", parent_id: nil, seq: 7, controller_action_id: 1, content_page_id: nil, label: "newlabel")
            @test7.save
            @test8 = MenuItem.new(name: "home8", parent_id: 1, seq: 8, controller_action_id: 2, content_page_id: nil, label: "newlabel")
            @test8.save
            @test9 = MenuItem.new(name: "home9", parent_id: 1, seq: 9, controller_action_id: 3, content_page_id: nil, label: "newlabel")
            @test9.save
	    expected_items = [@test7, @test8, @test9]
	    items = MenuItem.items_for_permissions
	    expect(items).to eq(expected_items)
	  end
        end
      end

      context 'when the controller_action_id of current item is smaller than or equal to 0 and the content_page_id of current item is bigger than 0' do
        context 'when perms does not exist' do
          it 'returns corresponding items' do
          # Write your test here!
            @test7 = MenuItem.new(name: "home7", parent_id: nil, seq: 7, controller_action_id: nil, content_page_id: 1, label: "newlabel")
            @test7.save
            @test8 = MenuItem.new(name: "home8", parent_id: 1, seq: 8, controller_action_id: nil, content_page_id: 2, label: "newlabel")
            @test8.save
            @test9 = MenuItem.new(name: "home9", parent_id: 1, seq: 9, controller_action_id: nil, content_page_id: 3, label: "newlabel")
            @test9.save
	    expected_items = [@test7, @test8, @test9]
	    items = MenuItem.items_for_permissions
	    expect(items).to eq(expected_items)
	  end
        end
      end

      context 'when the controller_action_id and content_page_id of current item is smaller than or equal to 0' do
        it 'returns corresponding items' do
        # Write your test here!
	  expect(MenuItem.items_for_permissions).to be_empty
	end
      end
    end

    context 'when inputted variable (permission_ids) is not nil' do
      context 'when the controller_action_id of current item is bigger than 0' do
        context 'when perms exists' do
          it 'returns corresponding items' do
          # Write your test here!
            @test7 = MenuItem.new(name: "home7", parent_id: nil, seq: 7, controller_action_id: 1, content_page_id: nil, label: "newlabel")
            @test7.save
            @test8 = MenuItem.new(name: "home8", parent_id: 1, seq: 8, controller_action_id: 2, content_page_id: nil, label: "newlabel")
            @test8.save
            @test9 = MenuItem.new(name: "home9", parent_id: 1, seq: 9, controller_action_id: 3, content_page_id: nil, label: "newlabel")
            @test9.save
	    expected_items = [@test7, @test8]
	    items = MenuItem.items_for_permissions([1])
	    expect(items).to eq(expected_items)
	  end
        end
      end

      context 'when the controller_action_id of current item is smaller than or equal to 0 and the content_page_id of current item is bigger than 0' do
        context 'when perms exists' do
          it 'returns corresponding items' do
          # Write your test here!
            @test7 = MenuItem.new(name: "home7", parent_id: nil, seq: 7, controller_action_id: nil, content_page_id: 1, label: "newlabel")
            @test7.save
            @test8 = MenuItem.new(name: "home8", parent_id: 1, seq: 8, controller_action_id: nil, content_page_id: 2, label: "newlabel")
            @test8.save
            @test9 = MenuItem.new(name: "home9", parent_id: 1, seq: 9, controller_action_id: nil, content_page_id: 3, label: "newlabel")
            @test9.save
	    expected_items = [@test7]
	    items = MenuItem.items_for_permissions([1])
	    expect(items).to eq(expected_items)
	  end
       end
      end

      context 'when the controller_action_id and content_page_id of current item is smaller than or equal to 0' do
        it 'returns corresponding items' do
        # Write your test here!
	  expect(MenuItem.items_for_permissions([1])).to be_empty
	end
      end
    end
  end
end
