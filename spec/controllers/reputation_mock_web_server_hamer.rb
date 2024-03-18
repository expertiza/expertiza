require "net/http"
require "json"

INPUTS = {
    "submission9999": {
    "stu9999": 10,
    "stu9998": 10,
    "stu9997": 9,
    "stu9996": 5
    },
      "submission9998": {
    "stu9999": 3,
    "stu9998": 2,
    "stu9997": 4,
    "stu9996": 5
    },
      "submission9997": {
    "stu9999": 7,
    "stu9998": 4,
    "stu9997": 5,
    "stu9996": 5
    },
      "submission9996": {
    "stu9999": 6,
    "stu9998": 4,
    "stu9997": 5,
    "stu9996": 5
    }
}.to_json

EXPECTED = {
    "Hamer": {
    "9996": 0.6,
    "9997": 3.6,
    "9998": 1.1,
    "9999": 1.1
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