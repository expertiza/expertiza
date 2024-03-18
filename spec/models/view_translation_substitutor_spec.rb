describe 'ViewTranslationSubstitutor' do
    let(:vts) { ViewTranslationSubstitutor.new }
    # The substitute method is currently broken in the actual model, this spec will fail
    # describe "#substitute" do
    #     it "returns" do
    #         locale = YAML.load_file('config/locales/en_US.yml')['en_US']
    #         expect(vts.substitute(locale)).to eq(?)
    #     end
    # end
end