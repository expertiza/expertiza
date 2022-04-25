class SentimentMetric extends Metric {
    constructor(URL) {
        super(
            URL
        );
    }

    format_response(response, analysis, metric_name, number_of_comments) {

        let combined_api_output = [];

        // loop through each comment
        for (let i = 0; i < number_of_comments; i++) {

            let single_output = {}
            single_output["Comment Number"] = i + 1;

            var pos;
            var neg;
            var neu;
            let response_sentiment = response[metric_name];
            pos = response_sentiment[String(analysis) + 's'][i]['pos'];
            neg = response_sentiment[String(analysis) + 's'][i]['neg'];
            neu = response_sentiment[String(analysis) + 's'][i]['neu'];
            
            // Add the sentiment values to the output
            if (pos > neg && pos > neu)
                single_output[metric_name] = 'Positive';
            if (neu > pos && neu > neg)
                single_output[metric_name] = 'Neutral';
            if (neg > neu && neg > pos)
                single_output[metric_name] = 'Negative';

            combined_api_output.push(single_output);
        }

        return combined_api_output;

    }
}