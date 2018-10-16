describe Node do
  ###
  # Use factories to `build` necessary objects.
  # Avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###
  
  # Write your mocked object here!
  let(:menu) { Menu.new }
  let(:node) { Menu::Node.new }

  describe "#initialize" do
    it "initializes the parent attribute"
    # Write your test here!
  end

  describe "#setup" do
    context "when the controller action attribute of the item is nil" do
      it "assigns content page path of the current menu item to the URL variable"
      # Write your test here!
    end

    context "when the controller action attribute of the item is not nil" do
      context "when the URL of the controller action is available" do
        it "assigns the URL of controller action to the URL variable"
        # Write your test here!
      end

      context "when the URL of the controller action is unavailable" do
        it "assigns a customized path to the URL variable"
        # Write your test here!
      end
    end
  end

  describe "#site_controller" do
    context "when the site_controller variable is nil" do
      it "finds the site controller by id"
      # Write your test here!
    end

    context "when the site_controller variable is not nil" do
      it "returns the site_controller variable"
      # Write your test here!
    end
  end

  describe "#controller_action" do
    context "when controller_action variable is nil" do
      it "finds the controller action by id"
      # Write your test here!
    end

    context "when the controller_action variable is not nil" do
      it "returns the controller action variable"
      # Write your test here!
    end
  end

  describe "#content_page" do
    context "when content_page variable is nil" do
      it "finds the content page by id"
      # Write your test here!
    end

    context "when the content_page variable is not nil" do
      it "returns the content page variable"
      # Write your test here!
    end
  end

  describe "#add_child" do
    it "adds a node to @children list and returns the list"
    # Write your test here!
  end
end

describe Menu do
  # Write your mocked object here!
  let(:menu) { Menu.new }
  let(:node) { Menu::Node.new }

  describe "#initialize" do
    context "when menu items are nil or empty" do
      it "terminates later initialization and returns nil"
      # Write your test here!
    end

    context "when menu items are not nil or empty" do
      context "when the parent id of the node is nil" do
        it "builds hashes of items by name and id and make the node as a child node of root node"
        # Write your test here!
      end

      context "when the parent id of the node is not nil" do
        it "builds hashes of items by name and id and make the node as a child node of its parent node"
        # Write your test here!
      end
    end
  end

  describe "#select" do
    context "when by_name hash does not contain the given node name" do
      it "returns nil"
      # Write your test here!
    end

    context "when by_name hash contains the given node name" do
      it "selects the menu item for the given name"
      # Write your test here!
    end
  end

  describe "#get_item" do
    it "returns menu item by id"
    # Write your test here!
  end

  describe "#get_menu" do
    it "returns the array of child nodes at the given level"
    # Write your test here!
  end

  describe "#selected" do
    it "returns the name of the currently-selected element"
    # Write your test here!
  end

  describe "#selected?" do
    context "when @selected hash contains menu_id" do
      it "returns true"
      # Write your test here!
    end

    context "when @selected hash does not contain menu_id" do
      it "returns false"
      # Write your test here!
    end
  end

  describe "#crumbs" do
    it "returns get a list of menu items based on contents in crumbs array"
    # Write your test here!
  end
end
