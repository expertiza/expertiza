class SentimentMetric extends Metric {
    constructor(api_call_values) {
        super(
            api_call_values['sentiment']['apiCall']
        );
    }

    async callAPI(input) {

        try{
            let response = await this.makeRequest(input);
            return JSON.parse(response);
        }
        catch(error){
            throw error;
        }
    }

   formatResponse(response,analysis,displayName,i){
        var pos;
        var neg;
        var neu;
        let response_sentiment = response[displayName];
        pos = response_sentiment[String(analysis)+'s'][i]['pos'];
        neg = response_sentiment[String(analysis)+'s'][i]['neg'];
        neu = response_sentiment[String(analysis)+'s'][i]['neu'];

        if ( pos > neg && pos > neu )
            return 'Positive';
        if ( neu > pos && neu > neg )
            return 'Neutral';
        if ( neg > neu && neg > pos )
            return 'Negative';
    }
}