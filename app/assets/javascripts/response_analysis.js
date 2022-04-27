// This .js file is used in app/views/response/_response_analysis.html.erb

//fetches the review form comments one by one - formats them into a single stringified json
function fetch_response_comments() {

    // This function fetches the comments from the review form and formats them into a single stringified json
    function create_comment_object(comment_id, review_id, question, class_name) {
        let comment_json = {};
        comment_json["id"] = comment_id + 1;
        let iframe_id = review_id >= 0 ? '#responses_' + review_id + '_comments_ifr' : '#review_comments_ifr';
        let comment_string = $(iframe_id).contents().find('body[data-id=' + class_name + ']').children().first().text();
        if (comment_string.length == 0) {
            return {};
        }
        comment_json["text"] = comment_string;
        comment_json["question"] = question;
        return comment_json;
    }

    // Looping over all elements present in the current page and fetching the ones 
    // which are the review questions based on the element id and 
    // finds element id of the comments in review form
    var review_element_ids = [];
    $("*").each(function () {
        current_element_id = this.id

        // if the current element id is a review question
        if (current_element_id && current_element_id.startsWith("responses_") && current_element_id.endsWith("_comments")) {
            review_element_ids.push(current_element_id);
        }

    });

    //for loop parses comments from review form and pushes all of them into 'reviews' list
    var reviews = [];
    for (var i = 0; i < review_element_ids.length; i++) {
        curr_review_element_id = review_element_ids[i]

        // if the current element id is not a review question
        if (document.getElementById(curr_review_element_id) == null)
            continue;
        else {
            let review_id = curr_review_element_id.split("_")[1]
            let question_class = 'responses_' + review_id;
            let question = $("label[for=" + question_class + "]").text();
            let class_name = "responses_" + review_id + "_comments";
            let comment_object = create_comment_object(i, review_id, question, class_name);
            if (Object.keys(comment_object).length > 0) {
                reviews.push(comment_object);
            }
        }
    }

    //fetches the 'additional comment' text present at the end of review form
    let comment_object = create_comment_object(-1, -1, "additional comments", 'review_comments');
    if (Object.keys(comment_object).length > 0) {
        reviews.push(comment_object);
    }

    // fetch the number of comments
    var number_of_comments = reviews.length;

    //converts the reviews list into a json object, which is later converted into stringified json.
    var processed_comment_json = {};
    processed_comment_json["reviews"] = reviews;
    processed_comment_json_string = JSON.stringify(processed_comment_json);

    return [processed_comment_json_string, number_of_comments]
}

//This function takes in the processed api output to display a table(populated with API output) on UI
function generate_table(responses, config_file_api_call_values, processed_comment_json, config_file_values) {

    // tooltip_json to store the text displayed in tooltip
    // Create a table header row using the extracted headers above.
    let tool_tips = { "Comment Number": 'The comment number from the top in the form.' };
    let metrics_to_check = ["Comment Number"];
    let column_names = ["Comment Number"];
    for (var metric in config_file_api_call_values) {
        // if the metric is not in the config file, then skip it
        if (config_file_values.includes(metric)) {
            metrics_to_check.push(config_file_api_call_values[metric]['className']);
            metric_string = String(metric);
            column_head = metric_string.substring(0, 1).toUpperCase() + metric_string.substring(1, metric_string.length);
            column_names.push(column_head);
            tool_tips[column_head] = config_file_api_call_values[metric]['toolTipText'];
        }
    }   

    // Create the table
    let table = document.createElement("table");
    let table_row = table.insertRow(-1);                   // table row.

    processed_comment_json_string = JSON.parse(processed_comment_json)['reviews'];

    // Create the table header
    for (let i = 0; i < column_names.length; i++) {
        var table_head = document.createElement("th");      // table header.
        table_head.innerHTML = column_names[i] + `<img src="/assets/info.png" title='` + tool_tips[column_names[i]] + `'>`;
        table_head.classList.add("parentCell_metric_table");
        table_row.appendChild(table_head);
    }

    // add json data to the table as rows.
    for (var i = 0; i < responses.length; i++) {
        table_row = table.insertRow(-1);

        for (var j = 0; j < metrics_to_check.length; j++) {
            var table_cell = table_row.insertCell(-1);
            table_cell.innerHTML = responses[i][metrics_to_check[j]]
            if (j == 0) {
                let title = "Q) " + processed_comment_json_string[i]['question'] + "\nA) " + processed_comment_json_string[i]['text'];
                table_cell.innerHTML += `<img src="/assets/info.png" title='` + title.replace("'", "") + `'>`;
            }
        }
    }

    // Now, add the newly created table with json data, to a container.
    var divShowData = document.getElementById('showData');
    divShowData.innerHTML = "";
    divShowData.appendChild(table);

    //provides conditional formatting to the generated table
    color();
}

// This function makes API calls
async function make_api_calls(config_file_api_call_values, config_file_values, processed_comment_json) {
    let analysis_response_dict = {};
    for (let metric in config_file_api_call_values) {
        // if the metric is not in the config file, then skip it
        if (config_file_values.includes(metric)) {
            // Converts the String object to the class object and calls the API from the class object
            metric_object_str = eval(config_file_api_call_values[metric]['className']);
            const metric_object = new metric_object_str(config_file_api_call_values[metric]['URL']);
            analysis_response_dict[config_file_api_call_values[metric]['className']] = await metric_object.call_API(processed_comment_json);
        }
    }
    return analysis_response_dict;
}

function combine_api_output(config_file_api_call_values, number_of_comments, config_file_values, analysis_response_dict) {
    // This loop combines the output received by API's in an array
    let responses = [];

    for (let i = 0; i < number_of_comments; i++) {
        let single_comment_output = {}
        single_comment_output["Comment Number"] = i + 1;
        for (let metric in config_file_api_call_values) {
            if (config_file_values.includes(metric)) {
                metric_object_str = eval(config_file_api_call_values[metric]['className']);
                const metric_object = new metric_object_str(config_file_api_call_values[metric]['URL']);
                single_comment_output[config_file_api_call_values[metric]['className']] = metric_object.format_response(analysis_response_dict, metric, config_file_api_call_values[metric]['className'], i);
            }
        }
        responses.push(single_comment_output);
    }
    return responses;
}

//The driver code to fetch the review comments, get API call output and display them in tabular format
async function get_review_feedback() {
    //this variable fetches and stores the review metrics setting stored in config file review_metrics.yml
    var config_file_values = $('.fetch_review_metric').data('params');

    //this variable fetches and stores the review metrics api urls stored in config file review_metrics_api_urls.yml
    var config_file_api_call_values = $('.fetch_review_metric_api_call_values').data('params');

    //displays text 'Loading...' when 'get review feedback' button is pressed until table is displayed
    var time_taken_obj = document.getElementById('timeTaken');
    time_taken_obj.innerHTML = "Loading..."

    //start the timer here - which will be used to calculate total time taken.
    var time_start = performance.now();
    let response_comments = fetch_response_comments();
    let processed_comment_json = response_comments[0];
    let number_of_comments = response_comments[1];

    //This holds the response value of each analysis as a dictionar/hash(key = analysis name, value = response of analysis)
    var analysis_response_dict = {};

    // function to make API calls
    analysis_response_dict = await make_api_calls(config_file_api_call_values, config_file_values, processed_comment_json);

    // function to combine the output received by API's in an array
    responses = combine_api_output(config_file_api_call_values, number_of_comments, config_file_values, analysis_response_dict);

    // function to display the output in tabular format
    generate_table(responses, config_file_api_call_values, processed_comment_json, config_file_values);

    // stop the timer here - which will be used to calculate total time taken.
    time_end = performance.now();
    var time_taken = time_end - time_start;
    var time_taken_obj = document.getElementById('timeTaken');

    //display the time taken in seconds
    time_taken_obj.innerHTML = `<p> Time taken is ${(time_taken / 1000).toFixed(2)} seconds. </p>`;

}

//This function does the conditional formatting of the output table on UI
function color() {
    $('td').each(
        function () {
            var score = $(this).text();
            if (score == 'Positive' || score == 'Present') {
                $(this).addClass('good');
            }
            else if (score == 'Neutral') {
                $(this).addClass('neutral');
            }
            else if (score == 'Negative' || score == 'Absent') {
                $(this).addClass('poor');
            }
        });
}