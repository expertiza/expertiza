describe MenuItem do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  #let(:test1) {MenuItem.new(name: "home", parent_id: nil, seq: 1, controller_action_id: 1, content_page_id: nil, label: "blah")}
  #let(:test2) {MenuItem.new(name: "home1", parent_id: 1, seq: 1, controller_action_id: 2, content_page_id: nil, label: "blah")}
  #let(:test3) {MenuItem.new(name: "home2", parent_id: 1, seq: 2, controller_action_id: 3, content_page_id: nil, label: "blah")}
  #let(:test4) {MenuItem.new(name: "home3", parent_id: 1, seq: 3, controller_action_id: 4, content_page_id: nil, label: "blah")}

  before(:each) do
    @test1 = MenuItem.new(name: "home1", parent_id: nil, seq: 1, controller_action_id: 1, content_page_id: nil, label: "blah")
    @test1.save
    @test2 = MenuItem.new(name: "home2", parent_id: 1, seq: 1, controller_action_id: 1, content_page_id: nil, label: "blah")
    @test2.save
    @test3 = MenuItem.new(name: "home3", parent_id: 1, seq: 2, controller_action_id: 1, content_page_id: nil, label: "blah")
    @test3.save
    @test4 = MenuItem.new(name: "home4", parent_id: 1, seq: 3, controller_action_id: 1, content_page_id: nil, label: "blah")
    @test4.save
    @test5 = MenuItem.new(name: "home5", parent_id: nil, seq: 2, controller_action_id: 1, content_page_id: nil, label: "blah")
    @test5.save
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
        puts MenuItem.count
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
