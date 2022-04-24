class ProblemMetric extends Metric {
    constructor(api_call_values) {
        super(
            api_call_values['problem']['apiCall']
        );
    }

    async callAPI(input) {
        // Transform the input into json
        // Call the api
        try{
            let response = await this.makeRequest(input);
            return JSON.parse(response);
        }
        catch(error){
            throw error;
        }
    }

    formatResponse(response,analysis,displayName,i){
        return response[displayName]['reviews'][i][String(analysis) + 's'];
    }
}