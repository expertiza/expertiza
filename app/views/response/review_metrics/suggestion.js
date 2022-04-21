class SuggestionMetric extends Metric {
    constructor() {
        super(
            "http://152.7.99.200:5000/suggestions",
            "Suggestion",
            'This shows whether any suggestion is mentioned in the comment or not'
        );
    }

    async callAPI(input) {
        //super.callAPI(input);
        // Transform the input into json
        let final_json = JSON.stringify({"text": input});

        // Call the api
        await this.makeRequest(final_json)
            .then(function (response) {
                // Format the response data
                return null;
                //return response.sentiment_tone; // Access the sentiment_tone value from the response and return it
            })
            .catch(function (error) {
                // An error occurred!
                console.log("An error occurred: " + error);
            });
    }
}