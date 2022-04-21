class SentimentMetric extends Metric {
    constructor() {
        super(
            "https://peerlogic.csc.ncsu.edu/sentiment/analyze_reviews_bulk",
            "Sentiment",
            'This column shows the tone of the comment.'
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
                return response.sentiment_tone; // Access the sentiment_tone value from the response and return it
            })
            .catch(function (error) {
                // An error occurred!
                console.log("An error occurred: " + error);
            });
    }
}