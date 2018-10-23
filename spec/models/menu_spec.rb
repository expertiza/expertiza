describe Menu do
	
	describe Node do
		
	end
	
	it "can be initialized" do
		menu = Menu.new
		expect(menu).not_to be_nil
	end
	
	
	describe ".select" do
		it "can find an existing menu item by name" do
			expect()
		end
		it "returns nil if no menu item matches the given name" do
			expect(menu.select("dne")).to be_nil
		end
	end

	describe ".get_item" do
	end

	describe ".get_menu" do
	end

	describe ".selected" do
	end

	describe ".selected?" do
	end

	describe ".crumbs" do
	end

end
