require 'rails_helper'

describe Checkbox do

  let(:checkbox){Checkbox.new id:10, type: "Checkbox", seq:1.0, txt:"test txt"}

  describe "#edit" do
    it "returns the html " do
      html = checkbox.edit(0).to_s
      expect(html).to eq("<tr><td align=\"center\"><a rel=\"nofollow\" data-method=\"delete\" href=\"/questions/10\">Remove</a></td><td><input size=\"6\" value=\"1.0\" name=\"question[10][seq]\" id=\"question_10_seq\" type=\"text\"></td><td><textarea cols=\"50\" rows=\"1\" name=\"question[10][txt]\" id=\"question_10_txt\">test txt</textarea></td><td><input size=\"10\" disabled=\"disabled\" value=\"Checkbox\" name=\"question[10][type]\" id=\"question_10_type\" type=\"text\"></td><td><!--placeholder (UnscoredQuestion does not need weight)--></td></tr>")
    end
  end

end

