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
        "passing3": 1.23,
    }
}.to_json

describe "Expertiza" do
    it "should return the correct Hamer calculation" do
        uri = URI('http://peerlogic.csc.ncsu.edu/reputation/calculations/reputation_algorithms')
    
        response = Net::HTTP.post(uri, INPUTS, 'Content-Type' => 'application/json')
    
        expect(JSON.parse(response.body)["Hamer"]).to eq(JSON.parse(EXPECTED)["Hamer"])
    end
end

describe "Expertiza Web Service" do
    it "should return the correct Hamer calculation" do
        uri = URI('https://4dfaead4-a747-4be4-8683-3b10d1d2e0c0.mock.pstmn.io/reputation_web_service/default')
    
        response = Net::HTTP.post(uri, INPUTS, 'Content-Type' => 'application/json')
        expect(JSON.parse("#{response.body}}")["Hamer"]).to eq(JSON.parse(EXPECTED)["Hamer"])
    end
end
