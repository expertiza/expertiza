describe Hamer do
    include Hamer 
    
    describe "#converged?" do
        context "when lists a and b are the same size with precision 2" do
            it "returns true" do
                a = [1.234, 2.35, 3.1415]
                b = [1.232, 2.354, 3.1439]
                expect(Hamer.converged?(a,b)).to eq(true)
            end
        end
    end
end