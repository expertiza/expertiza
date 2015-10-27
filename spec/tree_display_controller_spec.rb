equire 'rails_helper'

describe TreeDisplayController do¬
  let (:tree_display_controller) {TreeDisplayController.new}¬
  describe "#filter" do
    it "filters the search string" do
      tree_display_controller.should_receive(:filter).with("assignment")
    end
  end
end

