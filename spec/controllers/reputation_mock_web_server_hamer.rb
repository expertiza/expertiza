require "net/http"
require "json"

INPUTS = {
    "submission1": {
        "maxtoall": 10,
        "mintoall": 1,
        "mediantoall": 5,
        "incomplete_review": 4,
        "max_incomplete": 10,
        "min_incomplete": nil,
        "sametoall":3,
        "passing1": 10,
        "passing2": 10,
        "passing3": 9
    },
    "submission2": {
        "maxtoall": 10,
        "mintoall": 1,
        "mediantoall": 5,
        "incomplete_review": 2,
        "max_incomplete": 10,
        "min_incomplete": 1,
        "sametoall":3,
        "passing1": 3,
        "passing2": 2,
        "passing3": 4
    },
    "submission3": {
        "maxtoall": 10,
        "mintoall": 1,
        "mediantoall": 5,
        "incomplete_review": nil,
        "max_incomplete": nil,
        "min_incomplete": nil,
        "sametoall":3,
        "passing1": 7,
        "passing2": 4,
        "passing3": 5
    },
    "submission4": {
        "maxtoall": 10,
        "mintoall": 1,
        "mediantoall": 5,
        "incomplete_review": nil,
        "max_incomplete": 10,
        "min_incomplete": 1,
        "sametoall":3,
        "passing1": 6,
        "passing2": 4,
        "passing3": 5
    }
}.to_json

EXPECTED = {
    "Hamer": {
        "maxtoall": 2.65,
        "mintoall": 2.41,
        "mediantoall": 1.03,
        "incomplete_review": 2.31,
        "max_incomplete": 2.57,
        "min_incomplete": 2.48,
        "sametoall":1.58,
        "passing1": 2.17,
        "passing2": 1.73,
        "passing3": 1.23}
}.to_json

submissions = JSON.parse(INPUTS)
maxtoall_marks = []
mintoall_marks = []
mediantoall_marks = []
incomplete_review_marks = []
max_incomplete_marks = []
min_incomplete_marks = []
sametoall_marks = []
passing1_marks = []
passing2_marks = []
passing3_marks = []

submissions.each do |_submission_id, marks|
  maxtoall_marks << marks["maxtoall"]
  mintoall_marks << marks["mintoall"]
  mediantoall_marks << marks["mediantoall"]
  incomplete_review_marks << marks["incomplete_review"]
  max_incomplete_marks << marks["max_incomplete"]
  min_incomplete_marks << marks["min_incomplete"]
  sametoall_marks << marks["sametoall"]
  passing1_marks << marks["passing1"]
  passing2_marks << marks["passing2"]
  passing3_marks << marks["passing3"]
end

reviews = [
  maxtoall_marks,
  mintoall_marks,
  mediantoall_marks,
  incomplete_review_marks,
  max_incomplete_marks,
  min_incomplete_marks,
  sametoall_marks,
  passing1_marks,
  passing2_marks,
  passing3_marks
]



describe ReputationWebServiceController do
    it "should calculate correct Hamer calculation" do
      weights = ReputationWebServiceController.new.calculate_reputation_score(reviews)
      keys = ["maxtoall", "mintoall", "mediantoall", "incomplete_review", "max_incomplete_marks", "min_incomplete_marks", "sametoall", "passing1", "passing2", "passing3"]
      rounded_weights = weights.map { |w| w.round(1) }
      result_hash = keys.zip(rounded_weights).to_h
      expect(result_hash).to eq(JSON.parse(EXPECTED)["Hamer"])
    end
end


# describe "Expertiza" do
#     it "should return the correct Hamer calculation" do
#         uri = URI('http://peerlogic.csc.ncsu.edu/reputation/calculations/reputation_algorithms')
    
#         response = Net::HTTP.post(uri, INPUTS, 'Content-Type' => 'application/json')
    
#         expect(JSON.parse(response.body)["Hamer"]).to eq(JSON.parse(EXPECTED)["Hamer"])
#     end
# end


# describe "Expertiza Web Service" do
#     it "should return the correct Hamer calculation" do
#         uri = URI('https://4dfaead4-a747-4be4-8683-3b10d1d2e0c0.mock.pstmn.io/reputation_web_service/default')
    
#         response = Net::HTTP.post(uri, INPUTS, 'Content-Type' => 'application/json')
#         expect(JSON.parse("#{response.body}}")["Hamer"]).to eq(JSON.parse(EXPECTED)["Hamer"])
#     end
# end
