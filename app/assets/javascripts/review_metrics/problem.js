class ProblemMetric extends Metric {
    constructor(URL) {
        super(
            URL
        );
    }

    format_response(response,analysis,metric_name,number_of_comments){

        let combined_api_output = [];
        for(let i=0;i<number_of_comments;i++){

            let single_output = {}
            single_output["Comment Number"] = i+1;
            
            single_output[metric_name] = response[metric_name]['reviews'][i][String(analysis) + 's'];
            combined_api_output.push(single_output);
        }

        return combined_api_output;
        
    }
}