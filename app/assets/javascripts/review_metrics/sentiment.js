class SentimentMetric extends Metric {
    constructor(URL) {
        super(
            URL
        );
    }

    format_response(response, analysis, metric_name, i) {
        // check for the sentiment values in the response 
        var pos;
        var neg;
        var neu;
        let response_sentiment = response[metric_name];
        pos = response_sentiment[String(analysis) + 's'][i]['pos'];
        neg = response_sentiment[String(analysis) + 's'][i]['neg'];
        neu = response_sentiment[String(analysis) + 's'][i]['neu'];
        
        // Add the sentiment values to the output
        if (pos > neg && pos > neu)
            return 'Positive';
        if (neu > pos && neu > neg)
            return 'Neutral';
        if (neg > neu && neg > pos)
            return 'Negative';

    }
}