class SimicheckComparison < ActiveRecord::Base
    belongs_to :assignment
    validates :fileType, presence: true
    validates :assignment_id, :presence=>true
    validates :comparison_key, presence=> true

    def self.create_simicheck_comparison(assignment_id,fileType)
        url = "http://simicheck.com/api/comparison"
        key = "65f31df7af2c49e89a615a2602ce2faaa92380ab499e414fba6092adb0e71b3dd4674c86271f4b26b891f76c7709cbe574467477cfc84f2791e6f3f7827f3982"
        payload = ""

        response = RestClient.put(url, payload, {:simicheck_api_key=>key})
        if(response.code == 200)
            comparison_key = JSON.parse(response.body).id
            comparison = SimicheckComparison.create({ :assignment_id => assignment_id, :comparison_key => comparison_key, :fileType => fileType })
        end

        return nil
    end

    def self.send_file_to_simicheck(comparison_id, file, fileType)
            url = "http://simicheck.com/api/files/" + comparison_id
            key = "65f31df7af2c49e89a615a2602ce2faaa92380ab499e414fba6092adb0e71b3dd4674c86271f4b26b891f76c7709cbe574467477cfc84f2791e6f3f7827f3982"

            payload = {:file => file}

            response = RestClient.put(url, payload, {:simicheck_api_key=>key})
            if(response.code == 200)
                return true
            end
            return false
    end
end