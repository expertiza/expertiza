class ProblemMetric extends Metric {
    constructor(URL) {
        super(
            URL
        );
    }

    format_response(response, analysis, metric_name, i) {  
        // Return the sentiment values to the output
        return response[metric_name]['reviews'][i][String(analysis) + 's'];
    }
}