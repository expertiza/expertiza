require 'rails_helper'
require 'rest-client'
describe "SimicheckComparison" do
  describe "validations" do
    it "simicheck comparison is valid" do
      simicheck_comparison = build(:simicheck_comparison)
      expect(simicheck_comparison).to be_valid
    end
  end

  describe "#comparison_key" do
    it "checks if comparison_key is 1" do
      simicheck_comparison = build(:simicheck_comparison)
      expect(simicheck_comparison.comparison_key).to eq("e3b2606bce964e199cf44d5fcfc6d6347c012690cef841ecb71396e7c3ca7e7a")
    end
  end

  describe "#file_type" do
    it "checks if file type is pdf" do
      simicheck_comparison = build(:simicheck_comparison)
      expect(simicheck_comparison.file_type).to eq("pdf")
    end
  end

  describe "#assignment_id" do
    it "checks if  assignment id is 1" do
      simicheck_comparison = build(:simicheck_comparison)
      expect(simicheck_comparison.assignment_id).to eq(1)
    end
  end

  #returns true if file has been sen successflly
  describe "#send_file_to_simicheck" do
    it "returns true if response.code equals 200" do
      simicheck_comparison = build(:simicheck_comparison)
      f = File.open("/tmp/test.html", "w+")
      f.write("test")
      f.close
      f = File.open("/tmp/test.html", "r")
      result = simicheck_comparison.send_file_to_simicheck(f)
      expect(result).to be_truthy
    end
  end

  describe "#create_simicheck_comparison" do
    it "returns an object of SimicheckCoparison if response.code equals 200" do
      simicheck_comparison = build(:simicheck_comparison)
      assignment = build(:assignment)
      #allow(SimicheckComparion,create).to receive(:assigment_id).and_return(nil)
      sim_comp = SimicheckComparison.create_simicheck_comparison(assignment.id,"pdf")
      expect(sim_comp).to be_an_instance_of(SimicheckComparison)
    end
  end

  #returns true if simcheck is called
  describe "#get_status" do
    it "returns true if respnse.code equals 200" do
      simicheck_comparison = build(:simicheck_comparison)
      status = simicheck_comparison.get_status
      expect(status).to be_truthy
    end
  end
end
